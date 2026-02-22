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
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fakers/profiling/gallery_faker.dart';
import '../../../../../fakers/profiling/horses_faker.dart';
import '../../../../../fakers/profiling/image_faker.dart';

class MockProfilingService extends Mock implements ProfilingService {}

class MockFileStorageService extends Mock implements FileStorageService {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockCacheDriver extends Mock implements CacheDriver {}

void main() {
  late MockProfilingService profilingService;
  late MockFileStorageService fileStorageService;
  late MockFileStorageDriver fileStorageDriver;
  late MockMediaPickerDriver mediaPickerDriver;
  late MockNavigationDriver navigationDriver;
  late MockCacheDriver cacheDriver;
  late OnboardingScreenPresenter presenter;

  setUpAll(() {
    registerFallbackValue(HorsesFaker.fakeDto());
    registerFallbackValue(GalleryFaker.fakeDto());
    registerFallbackValue(<File>[File('test.png')]);
    registerFallbackValue(<UploadUrlDto>[]);
    registerFallbackValue(const UploadUrlDto(url: '', token: '', filePath: ''));
  });

  setUp(() {
    profilingService = MockProfilingService();
    fileStorageService = MockFileStorageService();
    fileStorageDriver = MockFileStorageDriver();
    mediaPickerDriver = MockMediaPickerDriver();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    presenter = OnboardingScreenPresenter(
      profilingService,
      fileStorageService,
      fileStorageDriver,
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

    test('should add image preview after picking a file', () async {
      when(
        () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
      ).thenAnswer((_) async => <File>[File('horses/image.png')]);

      await presenter.pickAndUploadImages();

      expect(presenter.uploadedImages.value, hasLength(1));
      expect(presenter.uploadedImages.value.first.name, 'image.png');
      expect(presenter.generalError.value, isNull);
      expect(presenter.isUploadingImages.value, isFalse);
    });

    test(
      'should not call storage service during pickAndUploadImages',
      () async {
        when(
          () =>
              mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
        ).thenAnswer((_) async => <File>[File('image.png')]);

        await presenter.pickAndUploadImages();

        verifyNever(
          () => fileStorageService.generateUploadUrlsForHorseGallery(
            horseId: any(named: 'horseId'),
            imagesNames: any(named: 'imagesNames'),
          ),
        );
      },
    );

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

    test(
      'should submit onboarding successfully (images pre-set, no pending files)',
      () async {
        fillValidForm();
        // Simulate images already set (e.g., re-entry scenario — no pending files).
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
      },
    );

    test(
      'should upload pending files and submit onboarding successfully',
      () async {
        fillValidForm();

        when(
          () =>
              mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
        ).thenAnswer((_) async => <File>[File('horses/photo.jpg')]);

        await presenter.pickAndUploadImages();
        await Future<void>.delayed(Duration.zero);

        final uploadUrls = <UploadUrlDto>[
          const UploadUrlDto(
            url: 'https://storage.example.com/upload',
            token: 'tok-1',
            filePath: 'horses/horse-1/photo.jpg',
          ),
        ];

        when(
          () => profilingService.createHorse(horse: any(named: 'horse')),
        ).thenAnswer(
          (_) async =>
              RestResponse<HorseDto>(body: HorsesFaker.fakeDto(id: 'horse-1')),
        );
        when(
          () => fileStorageService.generateUploadUrlsForHorseGallery(
            horseId: any(named: 'horseId'),
            imagesNames: any(named: 'imagesNames'),
          ),
        ).thenAnswer(
          (_) async => RestResponse<List<UploadUrlDto>>(body: uploadUrls),
        );
        when(
          () => fileStorageDriver.uploadFiles(any(), any()),
        ).thenAnswer((_) async {});
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

        verify(
          () => fileStorageService.generateUploadUrlsForHorseGallery(
            horseId: 'horse-1',
            imagesNames: any(named: 'imagesNames'),
          ),
        ).called(1);
        verify(() => fileStorageDriver.uploadFiles(any(), any())).called(1);
        verify(
          () => profilingService.createHorseGallery(
            horseId: 'horse-1',
            gallery: any(named: 'gallery'),
          ),
        ).called(1);
        verify(() => navigationDriver.goTo(Routes.home)).called(1);
        expect(presenter.generalError.value, isNull);
      },
    );

    test(
      'should set error when generate upload URLs fails during submission',
      () async {
        fillValidForm();

        when(
          () =>
              mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
        ).thenAnswer((_) async => <File>[File('photo.jpg')]);
        await presenter.pickAndUploadImages();
        await Future<void>.delayed(Duration.zero);

        when(
          () => profilingService.createHorse(horse: any(named: 'horse')),
        ).thenAnswer(
          (_) async =>
              RestResponse<HorseDto>(body: HorsesFaker.fakeDto(id: 'horse-1')),
        );
        when(
          () => fileStorageService.generateUploadUrlsForHorseGallery(
            horseId: any(named: 'horseId'),
            imagesNames: any(named: 'imagesNames'),
          ),
        ).thenAnswer(
          (_) async => RestResponse<List<UploadUrlDto>>(
            statusCode: 500,
            errorMessage: 'Erro ao gerar URLs',
          ),
        );

        await presenter.submitOnboarding();

        expect(presenter.generalError.value, 'Erro ao gerar URLs');
        verifyNever(
          () => profilingService.createHorseGallery(
            horseId: any(named: 'horseId'),
            gallery: any(named: 'gallery'),
          ),
        );
      },
    );

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
