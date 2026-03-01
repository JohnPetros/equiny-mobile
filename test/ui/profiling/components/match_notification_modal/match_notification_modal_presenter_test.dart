import 'dart:async';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/ui/profiling/components/match_notification_modal/match_notification_modal_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fakers/conversation/chat_faker.dart';
import '../../../../fakers/profiling/horse_match_faker.dart';
import '../../../../fakers/profiling/image_faker.dart';

class MockConversationService extends Mock implements ConversationService {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockCacheDriver extends Mock implements CacheDriver {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockConversationService conversationService;
  late MockNavigationDriver navigationDriver;
  late MockCacheDriver cacheDriver;
  late MockFileStorageDriver fileStorageDriver;
  late MatchNotificationModalPresenter presenter;

  setUp(() {
    conversationService = MockConversationService();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    fileStorageDriver = MockFileStorageDriver();

    when(() => cacheDriver.get(CacheKeys.ownerId)).thenReturn('sender-id');
    when(() => fileStorageDriver.getFileUrl(any())).thenAnswer(
      (invocation) => 'https://cdn/${invocation.positionalArguments.first}',
    );
    when(
      () =>
          conversationService.fetchChat(recipientId: any(named: 'recipientId')),
    ).thenAnswer(
      (_) async => RestResponse<ChatDto>(body: ChatFaker.fakeDto(id: 'chat-1')),
    );

    presenter = MatchNotificationModalPresenter(
      conversationService,
      navigationDriver,
      cacheDriver,
      fileStorageDriver,
    );
  });

  group('MatchNotificationModalPresenter', () {
    test('should initialize with default state', () {
      expect(presenter.queue.value, isEmpty);
      expect(presenter.currentMatch.value, isNull);
      expect(presenter.hasNext.value, isFalse);
      expect(presenter.horseImageUrl.value, isNull);
      expect(presenter.isCreatingChat.value, isFalse);
      expect(presenter.chatError.value, isNull);
    });

    test(
      'should expose current match and next state when queue has entries',
      () {
        final matches = HorseMatchFaker.fakeManyDto(length: 2);

        presenter.enqueue(matches[0]);
        presenter.enqueue(matches[1]);

        expect(presenter.currentMatch.value, matches[0]);
        expect(presenter.hasNext.value, isTrue);
      },
    );

    test('should resolve horse image url when current match has image key', () {
      presenter.enqueue(
        HorseMatchFaker.fakeDto(
          ownerHorseImage: ImageFaker.fakeDto(key: 'horse-image-key'),
        ),
      );

      expect(presenter.horseImageUrl.value, 'https://cdn/horse-image-key');
      verify(() => fileStorageDriver.getFileUrl('horse-image-key')).called(1);
    });

    test('should return null image url when horse image key is empty', () {
      presenter.enqueue(
        HorseMatchFaker.fakeDto(ownerHorseImage: ImageFaker.fakeDto(key: '  ')),
      );

      expect(presenter.horseImageUrl.value, isNull);
      verifyNever(() => fileStorageDriver.getFileUrl(any()));
    });

    test(
      'should create and open chat when fetch chat fails and create succeeds',
      () async {
        final match = HorseMatchFaker.fakeDto(ownerId: 'recipient-id');
        presenter.enqueue(match);

        when(
          () => conversationService.fetchChat(recipientId: 'recipient-id'),
        ).thenAnswer(
          (_) async =>
              RestResponse<ChatDto>(statusCode: 404, errorMessage: 'Not found'),
        );
        when(
          () => conversationService.createChat(recipientId: 'recipient-id'),
        ).thenAnswer(
          (_) async => RestResponse<ChatDto>(
            body: ChatFaker.fakeDto(id: 'created-chat-id'),
          ),
        );

        final didOpen = await presenter.handleGoToChat();

        expect(didOpen, isTrue);
        expect(presenter.isCreatingChat.value, isFalse);
        expect(presenter.chatError.value, isNull);
        verify(
          () => conversationService.fetchChat(recipientId: 'recipient-id'),
        ).called(1);
        verify(
          () => conversationService.createChat(recipientId: 'recipient-id'),
        ).called(1);
        verify(
          () => navigationDriver.goTo(Routes.chat, data: 'created-chat-id'),
        ).called(1);
      },
    );

    test('should set error when sender id is missing', () async {
      presenter.enqueue(HorseMatchFaker.fakeDto(ownerId: 'recipient-id'));
      when(() => cacheDriver.get(CacheKeys.ownerId)).thenReturn('');

      final didOpen = await presenter.handleGoToChat();

      expect(didOpen, isFalse);
      expect(
        presenter.chatError.value,
        'Nao foi possivel identificar o usuario.',
      );
      verifyNever(() => navigationDriver.goTo(any(), data: any(named: 'data')));
    });

    test('should set timeout message when chat request times out', () async {
      presenter.enqueue(HorseMatchFaker.fakeDto(ownerId: 'recipient-id'));
      when(
        () => conversationService.fetchChat(recipientId: 'recipient-id'),
      ).thenAnswer((_) async {
        throw TimeoutException('timeout');
      });

      final didOpen = await presenter.handleGoToChat();

      expect(didOpen, isFalse);
      expect(
        presenter.chatError.value,
        'A criacao do chat demorou mais que o esperado. Tente novamente.',
      );
    });

    test(
      'should remove current match and keep modal open when queue has next item',
      () {
        final matches = HorseMatchFaker.fakeManyDto(length: 2);
        presenter.queue.value = matches;

        final shouldClose = presenter.handleContinue();

        expect(shouldClose, isFalse);
        expect(presenter.currentMatch.value, matches[1]);
        expect(presenter.queue.value.length, 1);
      },
    );

    test('should clear queue state and errors', () {
      presenter.queue.value = HorseMatchFaker.fakeManyDto(length: 2);
      presenter.chatError.value = 'erro';
      presenter.isCreatingChat.value = true;

      presenter.clear();

      expect(presenter.queue.value, isEmpty);
      expect(presenter.chatError.value, isNull);
      expect(presenter.isCreatingChat.value, isFalse);
    });
  });
}
