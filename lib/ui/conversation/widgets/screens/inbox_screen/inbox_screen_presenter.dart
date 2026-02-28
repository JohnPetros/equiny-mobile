import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/conversation/events/message_received_event.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/events/owner_presence_registered_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_unregistered_event.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_channel.dart';
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

class InboxScreenPresenter {
  final ConversationService _conversationService;
  final ConversationChannel _conversationChannel;
  final ProfilingChannel _profilingChannel;
  final ProfilingService _profilingService;
  final CacheDriver _cacheDriver;
  final NavigationDriver _navigationDriver;
  final FileStorageDriver _fileStorageDriver;
  void Function()? _unsubscribeConversation;
  void Function()? _unsubscribePresence;
  bool _isRealtimeConnected = false;
  final Set<String> _presenceRequestsInFlight = <String>{};
  final Signal<Map<String, bool>> onlineRecipients = signal(<String, bool>{});

  final Signal<List<ChatDto>> chats = signal(<ChatDto>[]);
  final Signal<bool> isLoadingInitial = signal(false);
  final Signal<String?> errorMessage = signal(null);

  late final ReadonlySignal<List<ChatDto>> sortedChats;
  late final ReadonlySignal<int> unreadConversationsCount;
  late final ReadonlySignal<bool> isEmptyState;
  late final ReadonlySignal<bool> hasError;

  InboxScreenPresenter(
    this._conversationService,
    this._conversationChannel,
    this._profilingChannel,
    this._profilingService,
    this._cacheDriver,
    this._navigationDriver,
    this._fileStorageDriver,
  ) {
    sortedChats = computed(() {
      final List<ChatDto> items = <ChatDto>[...chats.value];
      items.sort((ChatDto a, ChatDto b) {
        return b.lastMessage.sentAt.compareTo(a.lastMessage.sentAt);
      });
      return items;
    });

    unreadConversationsCount = computed(() {
      return chats.value.where((ChatDto item) => item.unreadCount > 0).length;
    });

    hasError = computed(() => errorMessage.value != null);

    isEmptyState = computed(() {
      return !isLoadingInitial.value && !hasError.value && chats.value.isEmpty;
    });
  }

  void init() {
    unawaited(loadChats());
    connectRealtime();
  }

  void connectRealtime() {
    if (_isRealtimeConnected) {
      return;
    }

    _unsubscribeConversation = _conversationChannel.listen(
      onMessageReceived: _onMessageReceived,
    );
    _unsubscribePresence = _profilingChannel.listen(
      onOwnerPresenceRegistered: _onOwnerPresenceRegistered,
      onOwnerPresenceUnregistered: _onOwnerPresenceUnregistered,
      onHorseMatchNotified: (_) {},
    );
    _isRealtimeConnected = true;
  }

  void disconnectRealtime() {
    _unsubscribeConversation?.call();
    _unsubscribePresence?.call();
    _unsubscribeConversation = null;
    _unsubscribePresence = null;
    _isRealtimeConnected = false;
  }

  Future<void> retry() async {
    await loadChats();
  }

  Future<void> loadChats() async {
    isLoadingInitial.value = true;
    errorMessage.value = null;

    final response = await _conversationService.fetchChats();
    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      isLoadingInitial.value = false;
      return;
    }

    chats.value = response.body;
    _syncPresenceFromChats(response.body);
    unawaited(_fetchInitialPresenceForChats(response.body));
    isLoadingInitial.value = false;
  }

  bool isRecipientOnline(RecipientDto recipient) {
    final String recipientId = recipient.id ?? '';

    if (recipientId.isNotEmpty && onlineRecipients.value[recipientId] != null) {
      return onlineRecipients.value[recipientId] ?? false;
    }

    final DateTime? lastPresenceAt = recipient.lastPresenceAt;
    if (lastPresenceAt == null) {
      return false;
    }

    return DateTime.now().difference(lastPresenceAt).inMinutes < 5;
  }

  String formatRelativeTimestamp(DateTime sentAt) {
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime sentAtDay = DateTime(sentAt.year, sentAt.month, sentAt.day);

    if (sentAtDay == todayStart) {
      final String hour = sentAt.hour.toString().padLeft(2, '0');
      final String minute = sentAt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    if (sentAtDay == todayStart.subtract(const Duration(days: 1))) {
      return 'Ontem';
    }

    final DateTime startOfWeek = todayStart.subtract(
      Duration(days: todayStart.weekday - DateTime.monday),
    );
    if (!sentAtDay.isBefore(startOfWeek)) {
      return _weekdayName(sentAt.weekday);
    }

    final String day = sentAt.day.toString().padLeft(2, '0');
    final String month = sentAt.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String buildRecipientInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(' ')
        .where((String part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String resolveAvatarUrl(ImageDto? avatar) {
    final String key = avatar?.key ?? '';
    if (key.trim().isEmpty) {
      return '';
    }

    return _fileStorageDriver.getFileUrl(key);
  }

  void openChat(ChatDto chat) {
    _navigationDriver.goTo(Routes.chat, data: chat.id ?? '');
  }

  void goToMatches() {
    _navigationDriver.goTo(Routes.matches);
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    final String chatId = event.payload.chatId;
    final List<ChatDto> currentChats = <ChatDto>[...chats.value];
    final int index = currentChats.indexWhere(
      (ChatDto chat) => chat.id == chatId,
    );

    if (index == -1) {
      unawaited(_fetchMissingChat(chatId));
      return;
    }

    final ChatDto current = currentChats[index];
    final bool isIncoming =
        event.payload.message.senderId != _getCurrentOwnerId();
    final int unreadCount = isIncoming
        ? current.unreadCount + 1
        : current.unreadCount;

    currentChats[index] = ChatDto(
      id: current.id,
      recipient: current.recipient,
      lastMessage: event.payload.message,
      unreadCount: unreadCount,
    );

    chats.value = currentChats;
  }

  void _onOwnerPresenceRegistered(OwnerPresenceRegisteredEvent event) {
    final String ownerId = event.payload.ownerId;
    if (ownerId.isEmpty) {
      return;
    }

    onlineRecipients.value = <String, bool>{
      ...onlineRecipients.value,
      ownerId: true,
    };
  }

  void _onOwnerPresenceUnregistered(OwnerPresenceUnregisteredEvent event) {
    final String ownerId = event.payload.ownerId;
    if (ownerId.isEmpty) {
      return;
    }

    onlineRecipients.value = <String, bool>{
      ...onlineRecipients.value,
      ownerId: false,
    };
  }

  Future<void> _fetchMissingChat(String chatId) async {
    if (chatId.trim().isEmpty) {
      return;
    }

    final response = await _conversationService.fetchChats();
    if (response.isFailure) {
      return;
    }

    final ChatDto? resolvedChat = response.body.cast<ChatDto?>().firstWhere(
      (ChatDto? item) => item?.id == chatId,
      orElse: () => null,
    );
    if (resolvedChat == null) {
      return;
    }

    final List<ChatDto> currentChats = <ChatDto>[...chats.value];
    final bool alreadyExists = currentChats.any(
      (ChatDto chat) => chat.id == chatId,
    );
    if (alreadyExists) {
      return;
    }

    chats.value = <ChatDto>[...currentChats, resolvedChat];
  }

  String _getCurrentOwnerId() {
    return _cacheDriver.get(CacheKeys.ownerId) ?? '';
  }

  Future<void> _fetchInitialPresenceForChats(List<ChatDto> items) async {
    final Iterable<String> recipientIds = items
        .map((ChatDto chat) => chat.recipient.id ?? '')
        .where((String id) => id.trim().isNotEmpty)
        .toSet();

    await Future.wait(
      recipientIds.map((String ownerId) => _fetchRecipientPresence(ownerId)),
    );
  }

  Future<void> _fetchRecipientPresence(String ownerId) async {
    if (ownerId.isEmpty || _presenceRequestsInFlight.contains(ownerId)) {
      return;
    }

    _presenceRequestsInFlight.add(ownerId);
    final response = await _profilingService.fetchOwnerPresence(
      ownerId: ownerId,
    );
    _presenceRequestsInFlight.remove(ownerId);

    if (response.isFailure) {
      return;
    }

    onlineRecipients.value = <String, bool>{
      ...onlineRecipients.value,
      ownerId: response.body.isOnline,
    };
  }

  void _syncPresenceFromChats(List<ChatDto> items) {
    final Map<String, bool> next = <String, bool>{...onlineRecipients.value};
    final DateTime now = DateTime.now();

    for (final ChatDto chat in items) {
      final String recipientId = chat.recipient.id ?? '';
      final DateTime? lastPresenceAt = chat.recipient.lastPresenceAt;
      if (recipientId.isEmpty || lastPresenceAt == null) {
        continue;
      }

      next[recipientId] = now.difference(lastPresenceAt).inMinutes < 5;
    }

    onlineRecipients.value = next;
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Segunda';
      case DateTime.tuesday:
        return 'Terca';
      case DateTime.wednesday:
        return 'Quarta';
      case DateTime.thursday:
        return 'Quinta';
      case DateTime.friday:
        return 'Sexta';
      case DateTime.saturday:
        return 'Sabado';
      case DateTime.sunday:
      default:
        return 'Domingo';
    }
  }
}

final inboxScreenPresenterProvider = Provider.autoDispose<InboxScreenPresenter>(
  (ref) {
    final presenter = InboxScreenPresenter(
      ref.watch(conversationServiceProvider),
      ref.watch(conversationChannelProvider),
      ref.watch(profilingChannelProvider),
      ref.watch(profilingServiceProvider),
      ref.watch(cacheDriverProvider),
      ref.watch(navigationDriverProvider),
      ref.watch(fileStorageDriverProvider),
    );
    presenter.init();
    ref.onDispose(presenter.disconnectRealtime);
    return presenter;
  },
);
