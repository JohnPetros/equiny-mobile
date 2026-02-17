import 'dart:io';

import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_active_section/profile_horse_active_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/profile_horse_feed_readiness_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/profile_horse_form_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../fakers/profiling/gallery_faker.dart';
import '../../../../../../fakers/profiling/horses_faker.dart';
import '../../../../../../fakers/profiling/image_faker.dart';

class MockProfilingService extends Mock implements ProfilingService {}

class MockFileStorageService extends Mock implements FileStorageService {}

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

void main() {
  late MockProfilingService profilingService;
  late MockFileStorageService fileStorageService;
  late MockMediaPickerDriver mediaPickerDriver;
  late ProfileHorseTabPresenter presenter;

  setUpAll(() {
    registerFallbackValue(HorsesFaker.fakeDto());
    registerFallbackValue(GalleryFaker.fakeDto());
    registerFallbackValue(<File>[File('test.png')]);
  });

  setUp(() {
    profilingService = MockProfilingService();
    fileStorageService = MockFileStorageService();
    mediaPickerDriver = MockMediaPickerDriver();
    presenter = ProfileHorseTabPresenter(
      profilingService,
      fileStorageService,
      mediaPickerDriver,
      ProfileHorseFormSectionPresenter(),
      ProfileHorseFeedReadinessSectionPresenter(),
      ProfileHorseActiveSectionPresenter(),
    );
  });

  group('ProfileHorseTabPresenter', () {
    test('should initialize with expected defaults', () {
      expect(presenter.horseImages.value, isEmpty);
      expect(presenter.isLoadingInitialData.value, isFalse);
      expect(presenter.isSyncingHorse.value, isFalse);
      expect(presenter.isSyncingGallery.value, isFalse);
      expect(presenter.isUploadingImages.value, isFalse);
      expect(presenter.isHorseActive.value, isFalse);
      expect(
        presenter.remainingImagesCount.value,
        ProfileHorseTabPresenter.maxImages,
      );
      expect(presenter.feedReadinessChecklist.value, isNotEmpty);
      expect(presenter.canActivateHorse.value, isFalse);
    });

    test('should hydrate horse and gallery when loading succeeds', () async {
      final horse = HorsesFaker.fakeDto(
        id: 'horse-1',
        name: '  Relampago  ',
        breed: 'puro sangue ingles',
        sex: 'male',
        description: '  Forte e veloz  ',
        isActive: true,
      );
      final images = ImageFaker.fakeManyDto(length: 2);

      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(body: <HorseDto>[horse]),
      );
      when(
        () =>
            profilingService.fetchHorseGallery(horseId: any(named: 'horseId')),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(
          body: GalleryFaker.fakeDto(horseId: 'horse-1', images: images),
        ),
      );

      await presenter.loadHorseProfile();

      expect(presenter.horseForm.value.control('name').value, '  Relampago  ');
      expect(
        presenter.horseForm.value.control('breed').value,
        'puro sangue inglês',
      );
      expect(presenter.horseImages.value, images);
      expect(presenter.isHorseActive.value, isTrue);
      expect(presenter.generalError.value, isNull);
      expect(presenter.isLoadingInitialData.value, isFalse);
    });

    test('should set error when owner has no horses', () async {
      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(body: <HorseDto>[]),
      );

      await presenter.loadHorseProfile();

      expect(
        presenter.generalError.value,
        'Nenhum cavalo encontrado para este perfil.',
      );
      expect(presenter.isLoadingInitialData.value, isFalse);
    });

    test('should not sync horse when form is invalid', () async {
      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(
          body: <HorseDto>[HorsesFaker.fakeDto(id: 'horse-1')],
        ),
      );
      when(
        () =>
            profilingService.fetchHorseGallery(horseId: any(named: 'horseId')),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(body: GalleryFaker.fakeDto()),
      );
      await presenter.loadHorseProfile();

      presenter.horseForm.value.control('name').value = '';

      await presenter.syncHorsePatch();

      expect(
        presenter.generalError.value,
        'Preencha os campos obrigatorios antes de salvar.',
      );
      verifyNever(
        () => profilingService.updateHorse(horse: any(named: 'horse')),
      );
    });

    test('should sync horse and normalize data when form is valid', () async {
      final horse = HorsesFaker.fakeDto(
        id: 'horse-1',
        sex: 'male',
        breed: 'outra',
        isActive: false,
      );

      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(body: <HorseDto>[horse]),
      );
      when(
        () =>
            profilingService.fetchHorseGallery(horseId: any(named: 'horseId')),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(body: GalleryFaker.fakeDto()),
      );
      when(
        () => profilingService.updateHorse(horse: any(named: 'horse')),
      ).thenAnswer(
        (_) async => RestResponse<HorseDto>(
          body: HorsesFaker.fakeDto(id: 'horse-1', isActive: true),
        ),
      );
      await presenter.loadHorseProfile();

      presenter.horseForm.value.control('name').value = '  Tornado  ';
      presenter.horseForm.value.control('city').value = '  Campinas  ';
      presenter.horseForm.value.control('state').value = 'sp';
      presenter.horseForm.value.control('sex').value = 'male';
      presenter.horseForm.value.control('height').value = 1.75;
      presenter.horseForm.value.control('birthMonth').value = 3;
      presenter.horseForm.value.control('birthYear').value = 2021;

      await presenter.syncHorsePatch();

      final capturedHorse =
          verify(
                () => profilingService.updateHorse(
                  horse: captureAny(named: 'horse'),
                ),
              ).captured.single
              as HorseDto;
      expect(capturedHorse.name, 'Tornado');
      expect(capturedHorse.location.city, 'Campinas');
      expect(capturedHorse.location.state, 'SP');
      expect(presenter.isHorseActive.value, isTrue);
      expect(presenter.lastSyncAt.value, isNotNull);
    });

    test('should avoid sync when form signature did not change', () async {
      final horse = HorsesFaker.fakeDto(
        id: 'horse-1',
        name: 'Diamante',
        sex: 'male',
        breed: 'outra',
      );

      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(body: <HorseDto>[horse]),
      );
      when(
        () =>
            profilingService.fetchHorseGallery(horseId: any(named: 'horseId')),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(body: GalleryFaker.fakeDto()),
      );
      when(
        () => profilingService.updateHorse(horse: any(named: 'horse')),
      ).thenAnswer((_) async => RestResponse<HorseDto>(body: horse));

      await presenter.loadHorseProfile();
      await presenter.syncHorsePatch();

      verifyNever(
        () => profilingService.updateHorse(horse: any(named: 'horse')),
      );
    });

    test('should upload images and sync gallery', () async {
      final horse = HorsesFaker.fakeDto(
        id: 'horse-1',
        sex: 'male',
        breed: 'outra',
      );
      final pickedFiles = <File>[File('image-a.png')];
      final uploadedImages = ImageFaker.fakeManyDto(length: 2);

      when(() => profilingService.fetchOwnerHorses()).thenAnswer(
        (_) async => RestResponse<List<HorseDto>>(body: <HorseDto>[horse]),
      );
      when(
        () =>
            profilingService.fetchHorseGallery(horseId: any(named: 'horseId')),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(
          body: GalleryFaker.fakeDto(
            horseId: 'horse-1',
            images: const <ImageDto>[],
          ),
        ),
      );
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenAnswer((_) async => pickedFiles);
      when(
        () => fileStorageService.uploadImageFiles(files: any(named: 'files')),
      ).thenAnswer(
        (_) async => RestResponse<List<ImageDto>>(body: uploadedImages),
      );
      when(
        () => profilingService.updateHorseGallery(
          horseId: any(named: 'horseId'),
          gallery: any(named: 'gallery'),
        ),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(
          body: GalleryFaker.fakeDto(
            horseId: 'horse-1',
            images: uploadedImages,
          ),
        ),
      );
      await presenter.loadHorseProfile();

      await presenter.pickAndUploadImages();

      verify(
        () => mediaPickerDriver.pickImages(
          maxImages: ProfileHorseTabPresenter.maxImages,
        ),
      ).called(1);
      verify(
        () => fileStorageService.uploadImageFiles(files: pickedFiles),
      ).called(1);
      verify(
        () => profilingService.updateHorseGallery(
          horseId: 'horse-1',
          gallery: any(named: 'gallery'),
        ),
      ).called(1);
      expect(presenter.horseImages.value, uploadedImages);
      expect(presenter.generalError.value, isNull);
      expect(presenter.galleryError.value, isNull);
    });

    test('should set error when upload fails', () async {
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenAnswer((_) async => <File>[File('image.png')]);
      when(
        () => fileStorageService.uploadImageFiles(files: any(named: 'files')),
      ).thenAnswer(
        (_) async => RestResponse<List<ImageDto>>(
          statusCode: 400,
          errorMessage: 'Falha no upload',
        ),
      );

      await presenter.pickAndUploadImages();

      expect(presenter.galleryError.value, 'Falha no upload');
      expect(presenter.isUploadingImages.value, isFalse);
    });

    test('should set error when platform does not support picker', () async {
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenThrow(UnsupportedError('no'));

      await presenter.pickAndUploadImages();

      expect(
        presenter.galleryError.value,
        'Selecao de imagem nao suportada nesta plataforma/dispositivo.',
      );
      expect(presenter.isUploadingImages.value, isFalse);
    });

    test('should block activation when feed is not ready', () async {
      await presenter.toggleHorseActive(true);

      expect(
        presenter.generalError.value,
        'Seu cavalo ainda nao esta pronto para aparecer no feed.',
      );
      verifyNever(
        () => profilingService.updateHorse(horse: any(named: 'horse')),
      );
    });
  });
}
