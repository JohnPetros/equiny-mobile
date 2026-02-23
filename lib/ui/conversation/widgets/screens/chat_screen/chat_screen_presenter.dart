import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';
import 'package:equiny/core/conversation/events/chat_participant_entered_event.dart';
import 'package:equiny/core/conversation/events/message_sent_event.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
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
  final FileStorageDriver _fileStorageDriver;
  void Function()? _unsubscribeMessageReceived;

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
    this._fileStorageDriver,
  ) {
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
          draft.value.trim().isNotEmpty &&
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
    _unsubscribeMessageReceived ??= _conversationChannel.onMessageReceived(
      _onMessageReceived,
    );

    final String participantId = _resolveCurrentOwnerId();
    if (participantId.isNotEmpty) {
      await _conversationChannel.emitChatParticipantEnteredEvent(
        ChatParticipantEnteredEvent(
          chatId: _chatId,
          participantId: participantId,
        ),
      );
    }

    isSocketConnected.value = true;
  }

  Future<void> disconnectChannel() async {
    _unsubscribeMessageReceived?.call();
    _unsubscribeMessageReceived = null;
    isSocketConnected.value = false;
  }

  void onDraftChanged(String value) {
    draft.value = value;
  }

  Future<void> sendMessage({String? content}) async {
    final String text = (content ?? draft.value).trim();
    if (text.isEmpty || isSending.value) {
      return;
    }

    final ChatDto? currentChat = chat.value;
    final String recipientId = currentChat?.recipient.id ?? '';
    final String senderId = _resolveCurrentOwnerId();
    isSending.value = true;

    final MessageDto message = MessageDto(
      content: text,
      senderId: senderId,
      receiverId: recipientId,
      sentAt: DateTime.now(),
      isReadByRecipient: false,
      attachments: const [],
    );

    await _conversationChannel.emitMessageSentEvent(
      MessageSentEvent(
        messageContent: message.content,
        chatId: _chatId,
        senderId: senderId,
      ),
    );
    draft.value = '';
    isSending.value = false;
  }

  Future<void> sendSuggestedMessage(String content) async {
    await sendMessage(content: content);
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
        ref.watch(fileStorageDriverProvider),
      );
      ref.onDispose(() {
        unawaited(presenter.disconnectChannel());
      });
      presenter.init();
      return presenter;
    });
