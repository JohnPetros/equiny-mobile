import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';
import 'package:equiny/core/profiling/events/owner_presence_registered_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_unregistered_event.dart';
import 'package:equiny/core/profiling/interfaces/profiling_channel.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../fakers/conversation/recipient_faker.dart';
import '../../../../../../fakers/profiling/image_faker.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

class MockProfilingService extends Mock implements ProfilingService {}

class MockProfilingChannel extends Mock implements ProfilingChannel {}

void main() {
  late MockFileStorageDriver fileStorageDriver;
  late MockProfilingService profilingService;
  late MockProfilingChannel profilingChannel;
  late ChatHeaderPresenter presenter;

  setUp(() {
    fileStorageDriver = MockFileStorageDriver();
    profilingService = MockProfilingService();
    profilingChannel = MockProfilingChannel();

    when(
      () => profilingChannel.listen(
        onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
        onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
        onHorseMatchNotified: any(named: 'onHorseMatchNotified'),
      ),
    ).thenReturn(() {});

    presenter = ChatHeaderPresenter(
      fileStorageDriver,
      profilingService,
      profilingChannel,
    );
  });

  group('ChatHeaderPresenter', () {
    group('loadPresence', () {
      test('should set isRecipientOnline to true when online', () async {
        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: true,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isTrue);
        expect(presenter.presenceLabel.value, 'online');
      });

      test('should set presenceLabel with last seen date when offline', () async {
        final lastSeen = DateTime(2025, 6, 15, 14, 30);
        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: false,
              lastSeenAt: lastSeen,
            ),
          ),
        );

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          contains('visto por ultimo em'),
        );
      });

      test('should set fallback label when recipient id is empty', () async {
        final recipient = RecipientFaker.fakeDto(id: '');

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          'visto por ultimo em --/-- --:--',
        );
      });

      test('should set fallback label when recipient id is null', () async {
        const recipient = RecipientDto(id: null, name: 'Test');

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          'visto por ultimo em --/-- --:--',
        );
      });

      test('should use recipient lastPresenceAt when fetch fails', () async {
        final lastPresence = DateTime(2025, 3, 10, 9, 15);
        final recipient = RecipientDto(
          id: 'owner-1',
          name: 'Test',
          lastPresenceAt: lastPresence,
        );

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            errorMessage: 'Network error',
          ),
        );

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          contains('visto por ultimo em'),
        );
      });

      test('should set fallback when fetch fails and no lastPresenceAt', () async {
        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            errorMessage: 'Network error',
          ),
        );

        await presenter.loadPresence(recipient);

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          'visto por ultimo em --/-- --:--',
        );
      });
    });

    group('resolveAvatarUrl', () {
      test('should return file url when avatar key is present', () {
        final avatar = ImageFaker.fakeDto(key: 'avatars/pic.jpg');
        final recipient = RecipientFaker.fakeDto(avatar: avatar);

        when(
          () => fileStorageDriver.getFileUrl('avatars/pic.jpg'),
        ).thenReturn('https://cdn.example.com/avatars/pic.jpg');

        final result = presenter.resolveAvatarUrl(recipient);

        expect(result, 'https://cdn.example.com/avatars/pic.jpg');
      });

      test('should return empty string when avatar is null', () {
        final recipient = RecipientFaker.fakeDto();

        final result = presenter.resolveAvatarUrl(recipient);

        expect(result, '');
      });

      test('should return empty string when avatar key is empty', () {
        final avatar = ImageFaker.fakeDto(key: '');
        final recipient = RecipientFaker.fakeDto(avatar: avatar);

        final result = presenter.resolveAvatarUrl(recipient);

        expect(result, '');
      });

      test('should return empty string when avatar key is whitespace', () {
        final avatar = ImageFaker.fakeDto(key: '   ');
        final recipient = RecipientFaker.fakeDto(avatar: avatar);

        final result = presenter.resolveAvatarUrl(recipient);

        expect(result, '');
      });
    });

    group('disconnectRealtime', () {
      test('should unsubscribe from presence channel', () async {
        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: true,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.loadPresence(recipient);
        presenter.disconnectRealtime();

        verify(
          () => profilingChannel.listen(
            onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
            onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
            onHorseMatchNotified: any(named: 'onHorseMatchNotified'),
          ),
        ).called(1);
      });
    });

    group('realtime events', () {
      test('should set online when OwnerPresenceRegisteredEvent matches', () async {
        late void Function(OwnerPresenceRegisteredEvent) onRegistered;

        when(
          () => profilingChannel.listen(
            onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
            onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
            onHorseMatchNotified: any(named: 'onHorseMatchNotified'),
          ),
        ).thenAnswer((invocation) {
          onRegistered = invocation.namedArguments[#onOwnerPresenceRegistered]
              as void Function(OwnerPresenceRegisteredEvent);
          return () {};
        });

        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: false,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.loadPresence(recipient);

        onRegistered(
          OwnerPresenceRegisteredEvent(ownerId: 'owner-1'),
        );

        expect(presenter.isRecipientOnline.value, isTrue);
        expect(presenter.presenceLabel.value, 'online');
      });

      test('should ignore OwnerPresenceRegisteredEvent for different owner', () async {
        late void Function(OwnerPresenceRegisteredEvent) onRegistered;

        when(
          () => profilingChannel.listen(
            onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
            onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
            onHorseMatchNotified: any(named: 'onHorseMatchNotified'),
          ),
        ).thenAnswer((invocation) {
          onRegistered = invocation.namedArguments[#onOwnerPresenceRegistered]
              as void Function(OwnerPresenceRegisteredEvent);
          return () {};
        });

        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: false,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.loadPresence(recipient);

        onRegistered(
          OwnerPresenceRegisteredEvent(ownerId: 'other-owner'),
        );

        expect(presenter.isRecipientOnline.value, isFalse);
      });

      test('should set offline when OwnerPresenceUnregisteredEvent matches', () async {
        late void Function(OwnerPresenceUnregisteredEvent) onUnregistered;

        when(
          () => profilingChannel.listen(
            onOwnerPresenceRegistered: any(named: 'onOwnerPresenceRegistered'),
            onOwnerPresenceUnregistered: any(named: 'onOwnerPresenceUnregistered'),
            onHorseMatchNotified: any(named: 'onHorseMatchNotified'),
          ),
        ).thenAnswer((invocation) {
          onUnregistered = invocation
                  .namedArguments[#onOwnerPresenceUnregistered]
              as void Function(OwnerPresenceUnregisteredEvent);
          return () {};
        });

        final recipient = RecipientFaker.fakeDto(id: 'owner-1');

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'owner-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'owner-1',
              isOnline: true,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.loadPresence(recipient);

        onUnregistered(
          OwnerPresenceUnregisteredEvent(ownerId: 'owner-1'),
        );

        expect(presenter.isRecipientOnline.value, isFalse);
        expect(
          presenter.presenceLabel.value,
          contains('visto por ultimo em'),
        );
      });
    });
  });
}
