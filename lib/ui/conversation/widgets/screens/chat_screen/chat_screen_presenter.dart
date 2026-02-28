import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/conversation/events/message_sent_event.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/storage/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/document-picker-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/media-picker-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_presenter.dart';
import 'package:equiny/websocket/channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class ChatScreenPresenter {
  final String _chatId;
  final ConversationService _conversationService;
  final ConversationChannel _conversationChannel;
  final ProfilingService _profilingService;
  final NavigationDriver _navigationDriver;
  final CacheDriver _cacheDriver;
  final FileStorageService _fileStorageService;
  final FileStorageDriver _fileStorageDriver;
  late final ChatAttachmentPickerPresenter _chatAttachmentPickerPresenter;
  void Function()? _conversationChannelSubscription;

  String? _pendingMessageId;
  String? _pendingMessageText;
  final Map<String, MessageAttachmentDto> _uploadedAttachmentsByLocalId =
      <String, MessageAttachmentDto>{};

  static const int _pageSize = 30;

  final Signal<ChatDto?> chat = signal(null);
  final Signal<List<MessageDto>> messages = signal(<MessageDto>[]);
  final Signal<bool> isLoadingInitial = signal(false);
  final Signal<bool> isLoadingMore = signal(false);
  final Signal<bool> isSending = signal(false);
  final Signal<bool> isSocketConnected = signal(false);
  final Signal<String> draft = signal('');
  final Signal<String?> nextCursor = signal(null);
  final Signal<String?> errorMessage = signal(null);
  final Signal<bool> isRecipientOnline = signal(false);
  final Signal<List<PendingAttachment>> pendingAttachments = signal(
    <PendingAttachment>[],
  );
  final Signal<Map<String, AttachmentUploadStatus>> uploadStatusMap = signal(
    <String, AttachmentUploadStatus>{},
  );

  late final ReadonlySignal<bool> hasMessages;
  late final ReadonlySignal<bool> showEmptyState;
  late final ReadonlySignal<bool> canLoadMore;
  late final ReadonlySignal<bool> canSend;
  late final ReadonlySignal<List<ChatDateSectionDto>> groupedMessages;
  late final ReadonlySignal<String> headerSubtitle;

  ChatScreenPresenter(
    this._chatId,
    this._conversationService,
    this._conversationChannel,
    this._profilingService,
    this._navigationDriver,
    this._cacheDriver,
    this._fileStorageService,
    this._fileStorageDriver,
    MediaPickerDriver mediaPickerDriver,
    DocumentPickerDriver documentPickerDriver,
  ) {
    _chatAttachmentPickerPresenter = ChatAttachmentPickerPresenter(
      mediaPickerDriver,
      documentPickerDriver,
    );
    hasMessages = computed(() => messages.value.isNotEmpty);
    showEmptyState = computed(
      () =>
          !isLoadingInitial.value &&
          errorMessage.value == null &&
          !hasMessages.value,
    );
    canLoadMore = computed(() {
      return !isLoadingMore.value && (nextCursor.value ?? '').isNotEmpty;
    });
    canSend = computed(
      () =>
          !isSending.value &&
          (draft.value.trim().isNotEmpty ||
              pendingAttachments.value.isNotEmpty) &&
          isSocketConnected.value,
    );
    groupedMessages = computed(_buildGroupedMessages);
    headerSubtitle = computed(() {
      if (isRecipientOnline.value) {
        return 'Online agora';
      }
      final DateTime? lastPresenceAt = chat.value?.recipient.lastPresenceAt;
      if (lastPresenceAt == null) {
        return 'Visto recentemente';
      }
      return 'Visto por ultimo ${_formatDateTime(lastPresenceAt)}';
    });
  }

  void init() {
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    isLoadingInitial.value = true;
    errorMessage.value = null;

    await loadChat();
    if (chat.value == null) {
      isLoadingInitial.value = false;
      return;
    }

    await loadInitialMessages();
    await refreshPresence();
    isLoadingInitial.value = false;
  }

  Future<void> loadChat() async {
    final response = await _conversationService.fetchChat(chatId: _chatId);
    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      return;
    }

    chat.value = response.body;
  }

  Future<void> loadInitialMessages() async {
    final response = await _conversationService.fetchMessagesList(
      chatId: _chatId,
      limit: _pageSize,
      cursor: null,
    );
    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      return;
    }

    messages.value = _sortAndDedupe(response.body.items);
    nextCursor.value = response.body.nextCursor;
  }

  Future<void> loadMoreMessages() async {
    if (!canLoadMore.value) {
      return;
    }

    isLoadingMore.value = true;
    final response = await _conversationService.fetchMessagesList(
      chatId: _chatId,
      limit: _pageSize,
      cursor: nextCursor.value,
    );
    isLoadingMore.value = false;

    if (response.isFailure) {
      return;
    }

    messages.value = _sortAndDedupe(<MessageDto>[
      ...response.body.items,
      ...messages.value,
    ]);
    nextCursor.value = response.body.nextCursor;
  }

  Future<void> connectChannel() async {
    _conversationChannelSubscription ??= _conversationChannel.listen(
      onMessageReceived: (event) => _onMessageReceived(event.payload.message),
    );

    isSocketConnected.value = true;
  }

  Future<void> disconnectChannel() async {
    _conversationChannelSubscription?.call();
    _conversationChannelSubscription = null;
    isSocketConnected.value = false;
  }

  void onDraftChanged(String value) {
    draft.value = value;
  }

  Future<void> pickImageAttachments() async {
    await _pickAttachments(
      picker: () => _chatAttachmentPickerPresenter.pickImages(
        remainingSlots: _remainingAttachmentSlots,
      ),
    );
  }

  Future<void> pickDocumentAttachments() async {
    await _pickAttachments(
      picker: () => _chatAttachmentPickerPresenter.pickDocuments(
        remainingSlots: _remainingAttachmentSlots,
      ),
    );
  }

  void addPendingAttachments(List<PendingAttachment> attachments) {
    if (attachments.isEmpty) {
      return;
    }

    final List<PendingAttachment> next = <PendingAttachment>[
      ...pendingAttachments.value,
      ...attachments,
    ];
    pendingAttachments.value = next
        .take(ChatAttachmentPickerPresenter.maxAttachmentsPerMessage)
        .toList();
  }

  void removePendingAttachment(String localId) {
    pendingAttachments.value = pendingAttachments.value
        .where((PendingAttachment item) => item.localId != localId)
        .toList();
    _uploadedAttachmentsByLocalId.remove(localId);
  }

  Future<void> retryAttachmentUpload(String key) async {
    final PendingAttachment? pending = _findPendingByKey(key);
    if (pending == null) {
      return;
    }

    if ((_pendingMessageId ?? '').isEmpty) {
      await sendMessage();
      return;
    }

    await _uploadPendingAttachments(<PendingAttachment>[pending]);
    if (_failedAttachmentsForSocketEmit.isEmpty) {
      await _emitPendingSocketMessageIfPossible();
    }
  }

  Future<void> sendMessage({String? content}) async {
    final String text = (content ?? draft.value).trim();
    final List<PendingAttachment> validAttachments = _validPendingAttachments;

    if (isSending.value ||
        (text.isEmpty && validAttachments.isEmpty) ||
        !isSocketConnected.value) {
      return;
    }

    final String senderId = _resolveCurrentOwnerId();
    if (senderId.isEmpty) {
      return;
    }

    isSending.value = true;

    final messageResponse = await _conversationService.sendMessage(
      chatId: _chatId,
      content: text.isEmpty ? null : text,
      attachments: const <MessageAttachmentDto>[],
    );

    if (messageResponse.isFailure || (messageResponse.body.id ?? '').isEmpty) {
      errorMessage.value = messageResponse.errorMessage.isNotEmpty
          ? messageResponse.errorMessage
          : 'Nao foi possivel preparar o envio da mensagem.';
      isSending.value = false;
      return;
    }

    _pendingMessageId = messageResponse.body.id;
    _pendingMessageText = text;

    if (validAttachments.isNotEmpty) {
      await _uploadPendingAttachments(validAttachments);
    }

    await _emitPendingSocketMessageIfPossible(senderId: senderId);
    isSending.value = false;
  }

  Future<void> sendSuggestedMessage(String content) async {
    await sendMessage(content: content);
  }

  String resolveFileUrl(String key) {
    if (key.isEmpty) {
      return '';
    }
    return _fileStorageDriver.getFileUrl(key);
  }

  int get _remainingAttachmentSlots {
    return ChatAttachmentPickerPresenter.maxAttachmentsPerMessage -
        pendingAttachments.value.length;
  }

  List<PendingAttachment> get _validPendingAttachments {
    return pendingAttachments.value.where((PendingAttachment item) {
      return (item.errorMessage ?? '').isEmpty;
    }).toList();
  }

  List<PendingAttachment> get _failedAttachmentsForSocketEmit {
    return pendingAttachments.value.where((PendingAttachment item) {
      return item.status == AttachmentUploadStatus.failed;
    }).toList();
  }

  PendingAttachment? _findPendingByKey(String key) {
    for (final PendingAttachment pending in pendingAttachments.value) {
      final MessageAttachmentDto? uploaded =
          _uploadedAttachmentsByLocalId[pending.localId];
      if (pending.localId == key ||
          pending.name == key ||
          uploaded?.key == key) {
        return pending;
      }
    }
    return null;
  }

  Future<void> _pickAttachments({
    required Future<List<PendingAttachment>> Function() picker,
  }) async {
    if (_remainingAttachmentSlots <= 0) {
      return;
    }

    final List<PendingAttachment> picked = await picker();
    addPendingAttachments(picked);
  }

  void _updatePendingStatus({
    required String localId,
    required AttachmentUploadStatus status,
    String? errorMessage,
  }) {
    pendingAttachments.value = pendingAttachments.value.map((
      PendingAttachment item,
    ) {
      if (item.localId != localId) {
        return item;
      }
      return item.copyWith(
        status: status,
        errorMessage: errorMessage,
        clearErrorMessage: errorMessage == null,
      );
    }).toList();
  }

  Future<void> _uploadPendingAttachments(
    List<PendingAttachment> attachments,
  ) async {
    if ((_pendingMessageId ?? '').isEmpty || attachments.isEmpty) {
      return;
    }

    final List<StorageAttachmentDto> payload = attachments
        .map(
          (PendingAttachment attachment) => StorageAttachmentDto(
            kind: attachment.kind,
            name: attachment.name,
          ),
        )
        .toList();

    final uploadUrlsResponse = await _fileStorageService
        .generateUploadUrlsForAttachments(
          chatId: _chatId,
          messageId: _pendingMessageId!,
          attachments: payload,
        );

    if (uploadUrlsResponse.isFailure ||
        uploadUrlsResponse.body.length != attachments.length) {
      for (final PendingAttachment attachment in attachments) {
        _updatePendingStatus(
          localId: attachment.localId,
          status: AttachmentUploadStatus.failed,
          errorMessage: 'Nao foi possivel gerar URL de upload.',
        );
      }
      return;
    }

    await Future.wait(
      attachments.asMap().entries.map((entry) async {
        final int index = entry.key;
        final PendingAttachment attachment = entry.value;
        final uploadUrl = uploadUrlsResponse.body[index];

        _updatePendingStatus(
          localId: attachment.localId,
          status: AttachmentUploadStatus.sending,
        );

        final Map<String, AttachmentUploadStatus> sendingStatusMap =
            <String, AttachmentUploadStatus>{...uploadStatusMap.value};
        sendingStatusMap[uploadUrl.filePath] = AttachmentUploadStatus.sending;
        uploadStatusMap.value = sendingStatusMap;

        try {
          await _fileStorageDriver.uploadFile(attachment.file, uploadUrl);
          final MessageAttachmentDto dto = MessageAttachmentDto(
            kind: attachment.kind,
            key: uploadUrl.filePath,
            name: attachment.name,
            size: attachment.size,
          );
          _uploadedAttachmentsByLocalId[attachment.localId] = dto;

          final Map<String, AttachmentUploadStatus> nextUploadStatus =
              <String, AttachmentUploadStatus>{...uploadStatusMap.value};
          nextUploadStatus[dto.key] = AttachmentUploadStatus.ready;
          uploadStatusMap.value = nextUploadStatus;

          _updatePendingStatus(
            localId: attachment.localId,
            status: AttachmentUploadStatus.ready,
          );
        } catch (_) {
          final Map<String, AttachmentUploadStatus> failedStatusMap =
              <String, AttachmentUploadStatus>{...uploadStatusMap.value};
          failedStatusMap[uploadUrl.filePath] = AttachmentUploadStatus.failed;
          uploadStatusMap.value = failedStatusMap;

          _updatePendingStatus(
            localId: attachment.localId,
            status: AttachmentUploadStatus.failed,
            errorMessage: 'Falha no upload. Tente novamente.',
          );
        }
      }).toList(),
    );
  }

  Future<void> _emitPendingSocketMessageIfPossible({String? senderId}) async {
    final List<PendingAttachment> valid = _validPendingAttachments;
    final bool hasFailedUploads = _failedAttachmentsForSocketEmit.isNotEmpty;

    if (hasFailedUploads) {
      return;
    }

    final List<MessageAttachmentDto> attachments = valid
        .map(
          (PendingAttachment item) =>
              _uploadedAttachmentsByLocalId[item.localId],
        )
        .whereType<MessageAttachmentDto>()
        .toList();

    if (valid.length != attachments.length) {
      return;
    }

    final String resolvedSenderId = senderId ?? _resolveCurrentOwnerId();
    await _conversationChannel.emitMessageSentEvent(
      MessageSentEvent(
        messageContent: _pendingMessageText ?? draft.value.trim(),
        chatId: _chatId,
        senderId: resolvedSenderId,
        attachments: attachments,
      ),
    );

    draft.value = '';
    pendingAttachments.value = <PendingAttachment>[];
    _uploadedAttachmentsByLocalId.clear();
    _pendingMessageId = null;
    _pendingMessageText = null;
  }

  Future<void> refreshPresence() async {
    final String ownerId = chat.value?.recipient.id ?? '';
    if (ownerId.isEmpty) {
      isRecipientOnline.value = false;
      return;
    }

    final response = await _profilingService.fetchOwnerPresence(
      ownerId: ownerId,
    );
    if (response.isFailure) {
      return;
    }

    isRecipientOnline.value = response.body.isOnline;
  }

  void retry() {
    unawaited(_initialize());
  }

  void onBack() {
    if (_navigationDriver.canGoBack()) {
      _navigationDriver.goBack();
      return;
    }

    _navigationDriver.goTo(Routes.inbox);
  }

  String resolveRecipientAvatarUrl() {
    final String key = chat.value?.recipient.avatar?.key ?? '';
    if (key.isEmpty) {
      return '';
    }
    return _fileStorageDriver.getFileUrl(key);
  }

  String resolveRecipientName() {
    return chat.value?.recipient.name?.trim().isNotEmpty == true
        ? chat.value!.recipient.name!.trim()
        : 'Conversa';
  }

  bool isMine(MessageDto message) {
    final String recipientId = chat.value?.recipient.id ?? '';
    return message.senderId != recipientId;
  }

  void _onMessageReceived(MessageDto message) {
    final Map<String, AttachmentUploadStatus> nextUploadStatus =
        <String, AttachmentUploadStatus>{...uploadStatusMap.value};
    for (final MessageAttachmentDto attachment in message.attachments) {
      nextUploadStatus[attachment.key] = AttachmentUploadStatus.ready;
    }
    uploadStatusMap.value = nextUploadStatus;

    messages.value = _sortAndDedupe(<MessageDto>[...messages.value, message]);
  }

  String formatMessageHour(DateTime sentAt) {
    final String hour = sentAt.hour.toString().padLeft(2, '0');
    final String minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<ChatDateSectionDto> _buildGroupedMessages() {
    final Map<String, List<MessageDto>> grouped = <String, List<MessageDto>>{};
    for (final message in messages.value) {
      final DateTime date = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );
      grouped
          .putIfAbsent(date.toIso8601String(), () => <MessageDto>[])
          .add(message);
    }

    final List<DateTime> dates = grouped.keys.map(DateTime.parse).toList()
      ..sort((DateTime a, DateTime b) => a.compareTo(b));

    return dates.map((DateTime date) {
      final String key = date.toIso8601String();
      return ChatDateSectionDto(
        date: date,
        label: _formatDateLabel(date),
        messages: grouped[key] ?? <MessageDto>[],
      );
    }).toList();
  }

  List<MessageDto> _sortAndDedupe(List<MessageDto> items) {
    final Map<String, MessageDto> byKey = <String, MessageDto>{};
    for (final message in items) {
      final String key =
          message.id ??
          '${message.senderId}_${message.receiverId}_${message.sentAt.toIso8601String()}_${message.content}';
      byKey[key] = message;
    }
    final List<MessageDto> result = byKey.values.toList()
      ..sort((MessageDto a, MessageDto b) => a.sentAt.compareTo(b.sentAt));
    return result;
  }

  String _resolveCurrentOwnerId() {
    return _cacheDriver.get(CacheKeys.ownerId) ?? '';
  }

  String _formatDateLabel(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'HOJE';
    }

    if (date == yesterday) {
      return 'ONTEM';
    }

    const List<String> months = <String>[
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];

    final String day = date.day.toString().padLeft(2, '0');
    final String month = months[date.month - 1];
    return '$day DE $month';
  }

  String _formatDateTime(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

final chatScreenPresenterProvider = Provider.autoDispose
    .family<ChatScreenPresenter, String>((ref, chatId) {
      final presenter = ChatScreenPresenter(
        chatId,
        ref.watch(conversationServiceProvider),
        ref.watch(conversationChannelProvider),
        ref.watch(profilingServiceProvider),
        ref.watch(navigationDriverProvider),
        ref.watch(cacheDriverProvider),
        ref.watch(fileStorageServiceProvider),
        ref.watch(fileStorageDriverProvider),
        ref.watch(mediaPickerDriverProvider),
        ref.watch(documentPickerDriverProvider),
      );
      ref.onDispose(() {
        unawaited(presenter.disconnectChannel());
      });
      presenter.init();
      return presenter;
    });
