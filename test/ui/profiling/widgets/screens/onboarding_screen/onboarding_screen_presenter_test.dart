import 'dart:io';

import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fakers/profiling/gallery_faker.dart';
import '../../../../../fakers/profiling/horses_faker.dart';
import '../../../../../fakers/profiling/gallery_faker.dart';
import '../../../../../fakers/profiling/image_faker.dart';

class MockProfilingService extends Mock implements ProfilingService {}

class MockFileStorageService extends Mock implements FileStorageService {}

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockCacheDriver extends Mock implements CacheDriver {}

void main() {
  late MockProfilingService profilingService;
  late MockFileStorageService fileStorageService;
  late MockMediaPickerDriver mediaPickerDriver;
  late MockNavigationDriver navigationDriver;
  late MockCacheDriver cacheDriver;
  late OnboardingScreenPresenter presenter;

  setUpAll(() {
    registerFallbackValue(HorsesFaker.fakeDto());
    registerFallbackValue(GalleryFaker.fakeDto());
    registerFallbackValue(<File>[File('test.png')]);
  });

  setUp(() {
    profilingService = MockProfilingService();
    fileStorageService = MockFileStorageService();
    mediaPickerDriver = MockMediaPickerDriver();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    presenter = OnboardingScreenPresenter(
      profilingService,
      fileStorageService,
      mediaPickerDriver,
      navigationDriver,
      cacheDriver,
    );

    when(() => cacheDriver.set(any(), any())).thenAnswer((_) async {});
  });

  void fillValidForm() {
    presenter.form.value.control('name').value = '  Trovador  ';
    presenter.form.value.control('birthMonth').value = 5;
    presenter.form.value.control('birthYear').value = 2020;
    presenter.form.value.control('breed').value = 'Mangalarga';
    presenter.form.value.control('sex').value = 'Macho';
    presenter.form.value.control('height').value = 1.7;
    presenter.form.value.control('city').value = ' Sao Paulo ';
    presenter.form.value.control('state').value = 'sp';
    presenter.form.value.markAllAsTouched();
  }

  group('OnboardingScreenPresenter', () {
    test('should initialize with default state', () {
      expect(presenter.currentStepIndex.value, 0);
      expect(presenter.isSubmitting.value, isFalse);
      expect(presenter.isUploadingImages.value, isFalse);
      expect(presenter.submitAttempted.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.uploadedImages.value, isEmpty);
      expect(presenter.isFirstStep.value, isTrue);
      expect(presenter.isLastStep.value, isFalse);
      expect(presenter.canAdvance.value, isFalse);
      expect(presenter.canFinish.value, isFalse);
    });

    test('should not advance when current step is invalid', () {
      presenter.goNextStep();

      expect(presenter.currentStepIndex.value, 0);
      expect(presenter.submitAttempted.value, isTrue);
    });

    test('should advance when current step is valid', () async {
      presenter.form.value.control('name').value = 'Diamante';

      presenter.goNextStep();

      expect(presenter.currentStepIndex.value, 1);
      expect(presenter.submitAttempted.value, isFalse);
    });

    test('should not go back when already at first step', () {
      presenter.goPreviousStep();

      expect(presenter.currentStepIndex.value, 0);
    });

    test('should upload images and update state', () async {
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenAnswer((_) async => <File>[File('image.png')]);
      when(
        () => fileStorageService.uploadImageFiles(files: any(named: 'files')),
      ).thenAnswer(
        (_) async => RestResponse<List<ImageDto>>(
          body: ImageFaker.fakeManyDto(length: 2),
        ),
      );

      await presenter.pickAndUploadImages();

      expect(presenter.uploadedImages.value, hasLength(2));
      expect(presenter.generalError.value, isNull);
      expect(presenter.isUploadingImages.value, isFalse);
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

      expect(presenter.generalError.value, 'Falha no upload');
      expect(presenter.isUploadingImages.value, isFalse);
    });

    test('should set error when platform does not support picker', () async {
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenThrow(UnsupportedError('no'));

      await presenter.pickAndUploadImages();

      expect(
        presenter.generalError.value,
        'Selecao de imagem nao suportada nesta plataforma/dispositivo. Tente reiniciar o app.',
      );
      expect(presenter.isUploadingImages.value, isFalse);
    });

    test('should not pick images when reaching max', () async {
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(
        length: OnboardingScreenPresenter.maxImages,
      );

      await presenter.pickAndUploadImages();

      verifyNever(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      );
    });

    test('should remove images by key', () {
      final ImageDto imageA = ImageFaker.fakeDto(key: 'a');
      final ImageDto imageB = ImageFaker.fakeDto(key: 'b');
      presenter.uploadedImages.value = <ImageDto>[imageA, imageB];

      presenter.removeImage(imageA);

      expect(presenter.uploadedImages.value, <ImageDto>[imageB]);
    });

    test('should block submit when images are missing', () async {
      fillValidForm();
      await Future<void>.delayed(Duration.zero);

      await presenter.submitOnboarding();

      expect(
        presenter.generalError.value,
        'Envie ao menos uma imagem para concluir.',
      );
      verifyNever(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      );
    });

    test('should submit onboarding successfully', () async {
      fillValidForm();
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(length: 1);
      await Future<void>.delayed(Duration.zero);

      when(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      ).thenAnswer(
        (_) async =>
            RestResponse<HorseDto>(body: HorsesFaker.fakeDto(id: 'horse-1')),
      );
      when(
        () => profilingService.createHorseGallery(
          horseId: any(named: 'horseId'),
          gallery: any(named: 'gallery'),
        ),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(
          body: GalleryFaker.fakeDto(horseId: 'horse-1'),
        ),
      );

      await presenter.submitOnboarding();

      final HorseDto horse =
          verify(
                () => profilingService.createHorse(
                  horse: captureAny(named: 'horse'),
                ),
              ).captured.single
              as HorseDto;
      expect(horse.name, 'Trovador');
      expect(horse.location.city, 'Sao Paulo');
      expect(horse.location.state, 'SP');

      verify(
        () => profilingService.createHorseGallery(
          horseId: 'horse-1',
          gallery: any(named: 'gallery'),
        ),
      ).called(1);
      verify(
        () => cacheDriver.set(CacheKeys.onboardingCompleted, 'true'),
      ).called(1);
      verify(() => navigationDriver.goTo(Routes.home)).called(1);
      expect(presenter.generalError.value, isNull);
      expect(presenter.isSubmitting.value, isFalse);
    });

    test('should set error when create horse fails', () async {
      fillValidForm();
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(length: 1);
      await Future<void>.delayed(Duration.zero);

      when(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      ).thenAnswer(
        (_) async => RestResponse<HorseDto>(
          statusCode: 400,
          errorMessage: 'Erro ao criar',
        ),
      );

      await presenter.submitOnboarding();

      expect(presenter.generalError.value, 'Erro ao criar');
      verifyNever(
        () => profilingService.createHorseGallery(
          horseId: any(named: 'horseId'),
          gallery: any(named: 'gallery'),
        ),
      );
    });

    test('should set error when horse id is empty', () async {
      fillValidForm();
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(length: 1);
      await Future<void>.delayed(Duration.zero);

      when(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      ).thenAnswer(
        (_) async => RestResponse<HorseDto>(body: HorsesFaker.fakeDto(id: '')),
      );

      await presenter.submitOnboarding();

      expect(
        presenter.generalError.value,
        'Resposta invalida ao criar cavalo.',
      );
      verifyNever(
        () => profilingService.createHorseGallery(
          horseId: any(named: 'horseId'),
          gallery: any(named: 'gallery'),
        ),
      );
    });

    test('should set error when gallery creation fails', () async {
      fillValidForm();
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(length: 1);
      await Future<void>.delayed(Duration.zero);

      when(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      ).thenAnswer(
        (_) async =>
            RestResponse<HorseDto>(body: HorsesFaker.fakeDto(id: 'horse-1')),
      );
      when(
        () => profilingService.createHorseGallery(
          horseId: any(named: 'horseId'),
          gallery: any(named: 'gallery'),
        ),
      ).thenAnswer(
        (_) async => RestResponse<GalleryDto>(
          statusCode: 400,
          errorMessage: 'Erro galeria',
        ),
      );

      await presenter.submitOnboarding();

      expect(presenter.generalError.value, 'Erro galeria');
      verifyNever(() => cacheDriver.set(CacheKeys.onboardingCompleted, 'true'));
      verifyNever(() => navigationDriver.goTo(Routes.home));
    });

    test('should set generic error when exception is thrown', () async {
      fillValidForm();
      presenter.uploadedImages.value = ImageFaker.fakeManyDto(length: 1);
      await Future<void>.delayed(Duration.zero);

      when(
        () => profilingService.createHorse(horse: any(named: 'horse')),
      ).thenThrow(Exception('boom'));

      await presenter.submitOnboarding();

      expect(
        presenter.generalError.value,
        'Erro inesperado ao concluir onboarding.',
      );
    });
  });
}
