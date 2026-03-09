import 'dart:io';

import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../fakers/profiling/image_faker.dart';
import '../../../../../../fakers/profiling/owner_faker.dart';

class MockProfilingService extends Mock implements ProfilingService {}

class MockFileStorageService extends Mock implements FileStorageService {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

void main() {
  late MockProfilingService profilingService;
  late MockFileStorageService fileStorageService;
  late MockFileStorageDriver fileStorageDriver;
  late MockMediaPickerDriver mediaPickerDriver;
  late ProfileOwnerTabPresenter presenter;

  setUpAll(() {
    registerFallbackValue(OwnerFaker.fakeDto());
  });

  setUp(() {
    profilingService = MockProfilingService();
    fileStorageService = MockFileStorageService();
    fileStorageDriver = MockFileStorageDriver();
    mediaPickerDriver = MockMediaPickerDriver();
    presenter = ProfileOwnerTabPresenter(
      profilingService,
      fileStorageService,
      fileStorageDriver,
      mediaPickerDriver,
      ProfileOwnerFormSectionPresenter(),
    );
  });

  group('ProfileOwnerTabPresenter', () {
    test('should initialize with default values', () {
      expect(presenter.isLoadingOwner.value, isFalse);
      expect(presenter.isSyncingOwner.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.lastSyncAt.value, isNull);
      expect(presenter.ownerForm.value.contains('name'), isTrue);
      expect(presenter.ownerForm.value.contains('email'), isTrue);
      expect(presenter.ownerForm.value.contains('phone'), isTrue);
      expect(presenter.ownerForm.value.contains('bio'), isTrue);
    });

    test('should hydrate form when loadOwner succeeds', () async {
      final owner = OwnerFaker.fakeDto(
        name: '  Joao   Silva  ',
        phone: '11999999999',
        bio: 'Criador experiente',
      );
      when(
        () => profilingService.fetchOwner(),
      ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));

      await presenter.loadOwner();

      expect(presenter.isLoadingOwner.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.ownerForm.value.control('name').value, owner.name);
      expect(presenter.ownerForm.value.control('email').value, owner.email);
      expect(presenter.ownerForm.value.control('phone').value, owner.phone);
      expect(presenter.ownerForm.value.control('bio').value, owner.bio);
    });

    test('should set error when loadOwner fails', () async {
      when(() => profilingService.fetchOwner()).thenAnswer(
        (_) async => RestResponse<OwnerDto>(
          statusCode: 400,
          errorMessage: 'Falha ao buscar dono',
        ),
      );

      await presenter.loadOwner();

      expect(presenter.generalError.value, 'Falha ao buscar dono');
      expect(presenter.isLoadingOwner.value, isFalse);
    });

    test('should set generic error when loadOwner throws', () async {
      when(() => profilingService.fetchOwner()).thenThrow(Exception('boom'));

      await presenter.loadOwner();

      expect(
        presenter.generalError.value,
        'Erro inesperado ao carregar os dados do dono.',
      );
    });

    test('should not sync when owner was not loaded', () async {
      await presenter.syncOwnerPatch();

      verifyNever(
        () => profilingService.updateOwner(owner: any(named: 'owner')),
      );
    });

    test(
      'should sync owner patch when form is valid and has changes',
      () async {
        final owner = OwnerFaker.fakeDto(
          name: 'Joao Silva',
          email: 'joao@equiny.com',
          phone: '11999999999',
          bio: 'Bio antiga',
        );

        when(
          () => profilingService.fetchOwner(),
        ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));
        when(
          () => profilingService.updateOwner(owner: any(named: 'owner')),
        ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));

        await presenter.loadOwner();
        presenter.ownerForm.value.control('name').value = '  Joao   da Silva  ';
        presenter.ownerForm.value.control('bio').value = '  Nova   bio  ';

        await presenter.syncOwnerPatch();

        final OwnerDto sentOwner =
            verify(
                  () => profilingService.updateOwner(
                    owner: captureAny(named: 'owner'),
                  ),
                ).captured.single
                as OwnerDto;
        expect(sentOwner.name, 'Joao da Silva');
        expect(sentOwner.bio, 'Nova bio');
        expect(presenter.generalError.value, isNull);
        expect(presenter.isSyncingOwner.value, isFalse);
        expect(presenter.lastSyncAt.value, isNotNull);
      },
    );

    test('should set error when sync returns failure', () async {
      final owner = OwnerFaker.fakeDto();
      when(
        () => profilingService.fetchOwner(),
      ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));
      when(
        () => profilingService.updateOwner(owner: any(named: 'owner')),
      ).thenAnswer(
        (_) async => RestResponse<OwnerDto>(
          statusCode: 400,
          errorMessage: 'Falha ao sincronizar',
        ),
      );

      await presenter.loadOwner();
      presenter.ownerForm.value.control('name').value = 'Outro Nome';

      await presenter.syncOwnerPatch();

      expect(presenter.generalError.value, 'Falha ao sincronizar');
      expect(presenter.isSyncingOwner.value, isFalse);
    });

    test('should clear general error', () {
      presenter.generalError.value = 'Erro';

      presenter.clearError();

      expect(presenter.generalError.value, isNull);
    });

    test('should capture image from camera and sync owner avatar', () async {
      final owner = OwnerFaker.fakeDto();
      final imageFile = File('camera/avatar.jpg');
      const uploadUrl = UploadUrlDto(
        url: 'https://storage.example.com/upload',
        token: 'token-1',
        filePath: 'owners/owner-1/avatar.jpg',
      );
      final syncedOwner = OwnerDto(
        id: owner.id,
        name: owner.name,
        email: owner.email,
        accountId: owner.accountId,
        hasCompletedOnboarding: owner.hasCompletedOnboarding,
        avatar: ImageFaker.fakeDto(key: uploadUrl.filePath, name: 'avatar.jpg'),
        phone: owner.phone,
        bio: owner.bio,
      );

      when(
        () => profilingService.fetchOwner(),
      ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));
      when(
        () => mediaPickerDriver.pickImageFromCamera(),
      ).thenAnswer((_) async => imageFile);
      when(
        () => fileStorageService.generateUploadUrlForOwnerAvatar(
          ownerId: any(named: 'ownerId'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer((_) async => RestResponse<UploadUrlDto>(body: uploadUrl));
      when(
        () => fileStorageDriver.uploadFile(imageFile, uploadUrl),
      ).thenAnswer((_) async {});
      when(
        () => fileStorageDriver.getFileUrl(uploadUrl.filePath),
      ).thenReturn('https://cdn.example.com/${uploadUrl.filePath}');
      when(
        () => profilingService.updateOwner(owner: any(named: 'owner')),
      ).thenAnswer((_) async => RestResponse<OwnerDto>(body: syncedOwner));

      await presenter.loadOwner();
      await presenter.captureAndUploadAvatar();

      verify(() => mediaPickerDriver.pickImageFromCamera()).called(1);
      verify(
        () => fileStorageService.generateUploadUrlForOwnerAvatar(
          ownerId: 'owner-1',
          fileName: 'avatar.jpg',
        ),
      ).called(1);
      verify(
        () => fileStorageDriver.uploadFile(imageFile, uploadUrl),
      ).called(1);

      final OwnerDto sentOwner =
          verify(
                () => profilingService.updateOwner(
                  owner: captureAny(named: 'owner'),
                ),
              ).captured.single
              as OwnerDto;
      expect(sentOwner.avatar?.key, uploadUrl.filePath);
      expect(
        presenter.ownerAvatarUrl.value,
        'https://cdn.example.com/${uploadUrl.filePath}',
      );
      expect(presenter.avatarError.value, isNull);
      expect(presenter.isUploadingAvatar.value, isFalse);
    });

    test(
      'should not sync owner avatar when camera picker is cancelled',
      () async {
        final owner = OwnerFaker.fakeDto();

        when(
          () => profilingService.fetchOwner(),
        ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));
        when(
          () => mediaPickerDriver.pickImageFromCamera(),
        ).thenAnswer((_) async => null);

        await presenter.loadOwner();
        await presenter.captureAndUploadAvatar();

        verify(() => mediaPickerDriver.pickImageFromCamera()).called(1);
        verifyNever(
          () => fileStorageService.generateUploadUrlForOwnerAvatar(
            ownerId: any(named: 'ownerId'),
            fileName: any(named: 'fileName'),
          ),
        );
        verifyNever(
          () => profilingService.updateOwner(owner: any(named: 'owner')),
        );
        expect(presenter.avatarError.value, isNull);
        expect(presenter.isUploadingAvatar.value, isFalse);
      },
    );

    test(
      'should set camera error when platform does not support capture',
      () async {
        final owner = OwnerFaker.fakeDto();

        when(
          () => profilingService.fetchOwner(),
        ).thenAnswer((_) async => RestResponse<OwnerDto>(body: owner));
        when(
          () => mediaPickerDriver.pickImageFromCamera(),
        ).thenThrow(UnsupportedError('camera-not-supported'));

        await presenter.loadOwner();
        await presenter.captureAndUploadAvatar();

        expect(
          presenter.avatarError.value,
          'Camera nao suportada nesta plataforma/dispositivo.',
        );
        expect(presenter.isUploadingAvatar.value, isFalse);
      },
    );
  });
}
