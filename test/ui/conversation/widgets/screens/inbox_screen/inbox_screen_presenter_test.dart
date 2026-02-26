import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_channel.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fakers/conversation/chat_faker.dart';
import '../../../../../fakers/conversation/message_faker.dart';

class MockConversationService extends Mock implements ConversationService {}

class MockConversationChannel extends Mock implements ConversationChannel {}

class MockProfilingChannel extends Mock implements ProfilingChannel {}

class MockCacheDriver extends Mock implements CacheDriver {}

class MockProfilingService extends Mock implements ProfilingService {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockConversationService conversationService;
  late MockNavigationDriver navigationDriver;
  late MockFileStorageDriver fileStorageDriver;
  late MockConversationChannel conversationChannel;
  late MockProfilingChannel profilingChannel;
  late MockCacheDriver cacheDriver;
  late MockProfilingService profilingService;
  late InboxScreenPresenter presenter;

  setUp(() {
    conversationService = MockConversationService();
    navigationDriver = MockNavigationDriver();
    fileStorageDriver = MockFileStorageDriver();
    conversationChannel = MockConversationChannel();
    profilingChannel = MockProfilingChannel();
    cacheDriver = MockCacheDriver();
    profilingService = MockProfilingService();

    when(
      () => conversationChannel.listen(
        onMessageReceived: any(named: 'onMessageReceived'),
      ),
    ).thenReturn(() {});
    when(
      () => profilingChannel.listen(
        onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
        onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
      ),
    ).thenReturn(() {});
    when(() => cacheDriver.get(any())).thenReturn('owner-id');
    when(
      () => profilingService.fetchOwnerPresence(ownerId: any(named: 'ownerId')),
    ).thenAnswer(
      (_) async => RestResponse<OwnerPresenceDto>(
        body: const OwnerPresenceDto(
          ownerId: 'recipient-id',
          isOnline: false,
          lastSeenAt: null,
        ),
      ),
    );

    presenter = InboxScreenPresenter(
      conversationService,
      conversationChannel,
      profilingChannel,
      profilingService,
      cacheDriver,
      navigationDriver,
      fileStorageDriver,
    );
  });

  group('InboxScreenPresenter', () {
    test('should initialize with default state', () {
      expect(presenter.chats.value, isEmpty);
      expect(presenter.isLoadingInitial.value, isFalse);
      expect(presenter.errorMessage.value, isNull);
      expect(presenter.unreadConversationsCount.value, 0);
      expect(presenter.hasError.value, isFalse);
      expect(presenter.isEmptyState.value, isTrue);
    });

    test('should load chats successfully', () async {
      final chats = ChatFaker.fakeManyDto(length: 2);
      when(
        () => conversationService.fetchChats(),
      ).thenAnswer((_) async => RestResponse<List<ChatDto>>(body: chats));

      await presenter.loadChats();

      expect(presenter.isLoadingInitial.value, isFalse);
      expect(presenter.errorMessage.value, isNull);
      expect(presenter.chats.value, chats);
    });

    test('should set error when load chats fails', () async {
      when(() => conversationService.fetchChats()).thenAnswer(
        (_) async => RestResponse<List<ChatDto>>(
          statusCode: 500,
          errorMessage: 'Erro ao carregar conversas',
        ),
      );

      await presenter.loadChats();

      expect(presenter.isLoadingInitial.value, isFalse);
      expect(presenter.errorMessage.value, 'Erro ao carregar conversas');
      expect(presenter.hasError.value, isTrue);
    });

    test('should call loadChats when retry is called', () async {
      when(
        () => conversationService.fetchChats(),
      ).thenAnswer((_) async => RestResponse<List<ChatDto>>(body: const []));

      await presenter.retry();

      verify(() => conversationService.fetchChats()).called(1);
    });

    test('should call loadChats when init is called', () async {
      when(
        () => conversationService.fetchChats(),
      ).thenAnswer((_) async => RestResponse<List<ChatDto>>(body: const []));

      presenter.init();
      await Future<void>.delayed(Duration.zero);

      verify(() => conversationService.fetchChats()).called(1);
    });

    test('should keep chats sorted by last message date desc', () {
      final oldChat = ChatFaker.fakeDto(
        id: 'chat-old',
        lastMessage: MessageFaker.fakeDto(sentAt: DateTime(2026, 1, 1, 10, 0)),
      );
      final newChat = ChatFaker.fakeDto(
        id: 'chat-new',
        lastMessage: MessageFaker.fakeDto(sentAt: DateTime(2026, 1, 1, 12, 0)),
      );

      presenter.chats.value = <ChatDto>[oldChat, newChat];

      expect(
        presenter.sortedChats.value.map((chat) => chat.id).toList(),
        <String?>['chat-new', 'chat-old'],
      );
    });

    test('should count unread conversations correctly', () {
      presenter.chats.value = <ChatDto>[
        ChatFaker.fakeDto(unreadCount: 2),
        ChatFaker.fakeDto(unreadCount: 0),
        ChatFaker.fakeDto(unreadCount: 1),
      ];

      expect(presenter.unreadConversationsCount.value, 2);
    });

    test('should format timestamp as hour when date is today', () {
      final now = DateTime.now();
      final sentAt = DateTime(now.year, now.month, now.day, 9, 5);

      expect(presenter.formatRelativeTimestamp(sentAt), '09:05');
    });

    test('should format timestamp as ontem when date is yesterday', () {
      final sentAt = DateTime.now().subtract(const Duration(days: 1));

      expect(presenter.formatRelativeTimestamp(sentAt), 'Ontem');
    });

    test('should format timestamp as weekday name for same week day', () {
      final today = DateTime.now();
      final tomorrow = DateTime(today.year, today.month, today.day + 1);

      expect(
        presenter.formatRelativeTimestamp(tomorrow),
        isIn(<String>[
          'Segunda',
          'Terca',
          'Quarta',
          'Quinta',
          'Sexta',
          'Sabado',
          'Domingo',
        ]),
      );
    });

    test('should format timestamp as dd/MM for older dates', () {
      final sentAt = DateTime.now().subtract(const Duration(days: 10));
      final day = sentAt.day.toString().padLeft(2, '0');
      final month = sentAt.month.toString().padLeft(2, '0');

      expect(presenter.formatRelativeTimestamp(sentAt), '$day/$month');
    });

    test('should build recipient initials for name variations', () {
      expect(presenter.buildRecipientInitials('   '), '?');
      expect(presenter.buildRecipientInitials('Maria'), 'M');
      expect(presenter.buildRecipientInitials('Maria Silva'), 'MS');
    });

    test('should resolve avatar url when key is available', () {
      when(
        () => fileStorageDriver.getFileUrl('avatar-key'),
      ).thenReturn('https://cdn.equiny/avatar-key');

      final result = presenter.resolveAvatarUrl(
        const ImageDto(key: 'avatar-key', name: 'avatar.jpg'),
      );

      expect(result, 'https://cdn.equiny/avatar-key');
      verify(() => fileStorageDriver.getFileUrl('avatar-key')).called(1);
    });

    test('should return empty avatar url when key is empty', () {
      final result = presenter.resolveAvatarUrl(
        const ImageDto(key: '   ', name: 'avatar.jpg'),
      );

      expect(result, '');
      verifyNever(() => fileStorageDriver.getFileUrl(any()));
    });

    test('should navigate to chat with chat id when openChat is called', () {
      presenter.openChat(ChatFaker.fakeDto(id: 'chat-42'));

      verify(
        () => navigationDriver.goTo(Routes.chat, data: 'chat-42'),
      ).called(1);
    });

    test('should navigate to matches when goToMatches is called', () {
      presenter.goToMatches();

      verify(() => navigationDriver.goTo(Routes.matches)).called(1);
    });
  });
}
