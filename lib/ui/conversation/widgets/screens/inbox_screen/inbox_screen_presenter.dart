import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class InboxScreenPresenter {
  final ConversationService _conversationService;
  final NavigationDriver _navigationDriver;
  final FileStorageDriver _fileStorageDriver;

  final Signal<List<ChatDto>> chats = signal(<ChatDto>[]);
  final Signal<bool> isLoadingInitial = signal(false);
  final Signal<String?> errorMessage = signal(null);

  late final ReadonlySignal<List<ChatDto>> sortedChats;
  late final ReadonlySignal<int> unreadConversationsCount;
  late final ReadonlySignal<bool> isEmptyState;
  late final ReadonlySignal<bool> hasError;

  InboxScreenPresenter(
    this._conversationService,
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
    isLoadingInitial.value = false;
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
      ref.watch(navigationDriverProvider),
      ref.watch(fileStorageDriverProvider),
    );
    presenter.init();
    return presenter;
  },
);
