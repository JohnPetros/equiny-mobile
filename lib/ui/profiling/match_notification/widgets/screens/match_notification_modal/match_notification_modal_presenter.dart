import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class MatchNotificationModalPresenter {
  final ConversationService _conversationService;
  final NavigationDriver _navigationDriver;
  final CacheDriver _cacheDriver;
  final FileStorageDriver _fileStorageDriver;

  final Signal<List<HorseMatchDto>> queue = signal(<HorseMatchDto>[]);
  final Signal<bool> isCreatingChat = signal(false);
  final Signal<String?> chatError = signal(null);

  late final ReadonlySignal<HorseMatchDto?> currentMatch;
  late final ReadonlySignal<bool> hasNext;
  late final ReadonlySignal<String?> horseImageUrl;

  MatchNotificationModalPresenter(
    this._conversationService,
    this._navigationDriver,
    this._cacheDriver,
    this._fileStorageDriver,
  ) {
    currentMatch = computed(() {
      if (queue.value.isEmpty) {
        return null;
      }
      return queue.value.first;
    });

    hasNext = computed(() => queue.value.length > 1);

    horseImageUrl = computed(() {
      final String key = currentMatch.value?.ownerHorseImage?.key ?? '';
      if (key.trim().isEmpty) {
        return null;
      }
      return _fileStorageDriver.getFileUrl(key);
    });
  }

  void enqueue(HorseMatchDto match) {
    queue.value = <HorseMatchDto>[...queue.value, match];
  }

  void clear() {
    queue.value = <HorseMatchDto>[];
    chatError.value = null;
    isCreatingChat.value = false;
  }

  Future<bool> handleGoToChat() async {
    final HorseMatchDto? match = currentMatch.value;
    if (match == null || isCreatingChat.value) {
      return false;
    }

    final String senderId = _cacheDriver.get(CacheKeys.ownerId) ?? '';
    if (senderId.isEmpty) {
      chatError.value = 'Nao foi possivel identificar o usuario.';
      return false;
    }

    isCreatingChat.value = true;
    chatError.value = null;

    try {
      RestResponse<ChatDto> response = await _conversationService
          .fetchChat(recipientId: match.ownerId)
          .timeout(const Duration(seconds: 8));

      if (response.isFailure) {
        response = await _conversationService
            .createChat(recipientId: match.ownerId)
            .timeout(const Duration(seconds: 8));
      }

      if (response.isFailure) {
        chatError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Nao foi possivel abrir o chat.';
        return false;
      }

      final String chatId = response.body.id ?? '';
      if (chatId.isEmpty) {
        chatError.value = 'Nao foi possivel abrir o chat.';
        return false;
      }

      _navigationDriver.goTo(Routes.chat, data: chatId);
      return true;
    } on TimeoutException {
      chatError.value =
          'A criacao do chat demorou mais que o esperado. Tente novamente.';
      return false;
    } catch (_) {
      chatError.value = 'Nao foi possivel abrir o chat.';
      return false;
    } finally {
      isCreatingChat.value = false;
    }
  }

  bool handleContinue() {
    if (queue.value.isEmpty) {
      return true;
    }

    final List<HorseMatchDto> nextQueue = <HorseMatchDto>[...queue.value]
      ..removeAt(0);
    queue.value = nextQueue;
    chatError.value = null;
    return nextQueue.isEmpty;
  }

  bool handleClose() {
    return handleContinue();
  }
}

final matchNotificationModalPresenterProvider =
    Provider<MatchNotificationModalPresenter>((ref) {
      return MatchNotificationModalPresenter(
        ref.watch(conversationServiceProvider),
        ref.watch(navigationDriverProvider),
        ref.watch(cacheDriverProvider),
        ref.watch(fileStorageDriverProvider),
      );
    });
