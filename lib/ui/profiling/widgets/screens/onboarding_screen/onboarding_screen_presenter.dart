import 'dart:async';
import 'dart:io';

import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/media-picker-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class OnboardingScreenPresenter {
  static const int totalSteps = 7;
  static const int maxImages = 6;

  final ProfilingService _profilingService;
  final FileStorageService _fileStorageService;
  final FileStorageDriver _fileStorageDriver;
  final MediaPickerDriver _mediaPickerDriver;
  final NavigationDriver _navigationDriver;
  final CacheDriver _cacheDriver;

  final Signal<FormGroup> form = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<int> currentStepIndex = signal(0);
  final Signal<bool> isSubmitting = signal(false);
  final Signal<bool> isUploadingImages = signal(false);
  final Signal<bool> submitAttempted = signal(false);
  final Signal<String?> generalError = signal(null);
  final Signal<List<ImageDto>> uploadedImages = signal(<ImageDto>[]);
  final Signal<int> _formVersion = signal(0);

  /// Stores the actual [File] objects selected by the user, pending upload.
  final Signal<List<File>> _pendingFiles = signal(<File>[]);

  StreamSubscription<Object?>? _formValueSubscription;
  StreamSubscription<ControlStatus>? _formStatusSubscription;

  late final ReadonlySignal<bool> isFirstStep;
  late final ReadonlySignal<bool> isLastStep;
  late final ReadonlySignal<String> currentStepLabel;
  late final ReadonlySignal<bool> canAdvance;
  late final ReadonlySignal<bool> canFinish;

  final List<String> stepLabels = const <String>[
    'Nome',
    'Nascimento',
    'Raca',
    'Sexo',
    'Altura',
    'Localizacao',
    'Imagens',
  ];

  final List<String> breedOptions = const <String>[
    'Mangalarga',
    'Quarto de Milha',
    'Crioulo',
    'Pampa',
    'Campolina',
    'Outro',
  ];

  final List<String> sexOptions = const <String>['Macho', 'Femea'];

  OnboardingScreenPresenter(
    this._profilingService,
    this._fileStorageService,
    this._fileStorageDriver,
    this._mediaPickerDriver,
    this._navigationDriver,
    this._cacheDriver,
  ) {
    form.value = buildForm();
    _bindFormSignals();

    isFirstStep = computed(() => currentStepIndex.value == 0);
    isLastStep = computed(() => currentStepIndex.value == totalSteps - 1);
    currentStepLabel = computed(() => stepLabels[currentStepIndex.value]);
    canAdvance = computed(() {
      _formVersion.value;
      return !isSubmitting.value &&
          !isUploadingImages.value &&
          _isStepValid(currentStepIndex.value);
    });
    canFinish = computed(() {
      _formVersion.value;
      return !isSubmitting.value &&
          !isUploadingImages.value &&
          _isStepValid(totalSteps - 1) &&
          uploadedImages.value.isNotEmpty;
    });
  }

  void _bindFormSignals() {
    _formValueSubscription?.cancel();
    _formStatusSubscription?.cancel();

    _formValueSubscription = form.value.valueChanges.listen((_) {
      _formVersion.value = _formVersion.value + 1;
    });
    _formStatusSubscription = form.value.statusChanged.listen((_) {
      _formVersion.value = _formVersion.value + 1;
    });
  }

  void dispose() {
    _formValueSubscription?.cancel();
    _formStatusSubscription?.cancel();
  }

  FormGroup buildForm() {
    final int currentYear = DateTime.now().year;
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
      'birthMonth': FormControl<int>(
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'birthYear': FormControl<int>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(1980),
          Validators.max(currentYear),
        ],
      ),
      'breed': FormControl<String>(
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'sex': FormControl<String>(
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'height': FormControl<double>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(0.5),
          Validators.max(3.0),
        ],
      ),
      'city': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
        ],
      ),
      'state': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(2),
        ],
      ),
    });
  }

  bool validateCurrentStep() {
    submitAttempted.value = true;
    final List<String> controlNames = _stepControlNames(currentStepIndex.value);
    for (final String controlName in controlNames) {
      form.value.control(controlName).markAsTouched();
    }

    if (currentStepIndex.value == totalSteps - 1) {
      return uploadedImages.value.isNotEmpty;
    }

    return controlNames.every((String controlName) {
      return form.value.control(controlName).valid;
    });
  }

  void goNextStep() {
    generalError.value = null;
    if (isLastStep.value) {
      return;
    }

    if (!validateCurrentStep()) {
      return;
    }

    currentStepIndex.value = currentStepIndex.value + 1;
    submitAttempted.value = false;
  }

  void goPreviousStep() {
    generalError.value = null;
    if (isFirstStep.value) {
      return;
    }
    currentStepIndex.value = currentStepIndex.value - 1;
    submitAttempted.value = false;
  }

  /// Picks image files from the device and adds them as previews.
  ///
  /// The actual upload to storage happens during [submitOnboarding] after the
  /// horse is created (so that a valid [horseId] is available for generating
  /// pre-signed upload URLs).
  Future<void> pickAndUploadImages() async {
    generalError.value = null;
    if (isUploadingImages.value) {
      return;
    }

    final int remainingImages = maxImages - uploadedImages.value.length;
    if (remainingImages <= 0) {
      return;
    }

    isUploadingImages.value = true;
    try {
      final List<File> files = await _mediaPickerDriver.pickImages(
        maxImages: remainingImages,
      );
      if (files.isEmpty) {
        return;
      }

      _pendingFiles.value = <File>[..._pendingFiles.value, ...files];

      // Show local file previews while the real upload is deferred to submit.
      final List<ImageDto> previews = files.map((File file) {
        return ImageDto(key: file.path, name: file.uri.pathSegments.last);
      }).toList();

      uploadedImages.value = <ImageDto>[...uploadedImages.value, ...previews];
    } on UnsupportedError {
      generalError.value =
          'Selecao de imagem nao suportada nesta plataforma/dispositivo. Tente reiniciar o app.';
    } catch (error) {
      generalError.value = 'Erro inesperado ao selecionar imagens: $error';
    } finally {
      isUploadingImages.value = false;
    }
  }

  void removeImage(ImageDto image) {
    _pendingFiles.value = _pendingFiles.value
        .where((File file) => file.path != image.key)
        .toList();
    uploadedImages.value = uploadedImages.value
        .where((ImageDto current) => current.key != image.key)
        .toList();
  }

  Future<void> retryImageUpload() async {
    await pickAndUploadImages();
  }

  Future<void> submitOnboarding() async {
    submitAttempted.value = true;
    generalError.value = null;

    if (!canFinish.value) {
      if (uploadedImages.value.isEmpty) {
        generalError.value = 'Envie ao menos uma imagem para concluir.';
      }
      return;
    }

    isSubmitting.value = true;
    try {
      final HorseDto horse = HorseDto(
        name: (form.value.control('name').value as String? ?? '').trim(),
        birthMonth: form.value.control('birthMonth').value as int? ?? 0,
        birthYear: form.value.control('birthYear').value as int? ?? 0,
        breed: (form.value.control('breed').value as String? ?? '').trim(),
        sex: (form.value.control('sex').value as String? ?? '').trim(),
        height: form.value.control('height').value as double? ?? 0,
        location: LocationDto(
          city: (form.value.control('city').value as String? ?? '').trim(),
          state: (form.value.control('state').value as String? ?? '')
              .trim()
              .toUpperCase(),
        ),
      );

      final horseResponse = await _profilingService.createHorse(horse: horse);
      if (horseResponse.isFailure) {
        generalError.value = horseResponse.errorMessage;
        isSubmitting.value = false;
        return;
      }

      final String horseId = horseResponse.body.id ?? '';
      if (horseId.isEmpty) {
        generalError.value = 'Resposta invalida ao criar cavalo.';
        isSubmitting.value = false;
        return;
      }

      if (_pendingFiles.value.isNotEmpty) {
        final List<String> imageNames = _pendingFiles.value
            .map((File f) => f.uri.pathSegments.last)
            .toList();

        final uploadUrlsResponse = await _fileStorageService
            .generateUploadUrlsForHorseGallery(
              horseId: horseId,
              imagesNames: imageNames,
            );

        if (uploadUrlsResponse.isFailure) {
          generalError.value = uploadUrlsResponse.errorMessage;
          isSubmitting.value = false;
          return;
        }

        await _fileStorageDriver.uploadFiles(
          _pendingFiles.value,
          uploadUrlsResponse.body,
        );

        uploadedImages.value = uploadUrlsResponse.body
            .map(
              (uploadUrl) => ImageDto(
                key: uploadUrl.filePath,
                name: uploadUrl.filePath.split('/').last,
              ),
            )
            .toList();
      }

      final galleryResponse = await _profilingService.createHorseGallery(
        horseId: horseId,
        gallery: GalleryDto(horseId: horseId, images: uploadedImages.value),
      );

      if (galleryResponse.isFailure) {
        generalError.value = galleryResponse.errorMessage;
        isSubmitting.value = false;
        return;
      }

      _cacheDriver.set(CacheKeys.onboardingCompleted, 'true');
      _navigationDriver.goTo(Routes.home);
    } catch (_) {
      generalError.value = 'Erro inesperado ao concluir onboarding.';
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _isStepValid(int index) {
    if (index == totalSteps - 1) {
      return uploadedImages.value.isNotEmpty;
    }

    final List<String> controls = _stepControlNames(index);
    return controls.every((String controlName) {
      return form.value.control(controlName).valid;
    });
  }

  List<String> _stepControlNames(int index) {
    switch (index) {
      case 0:
        return <String>['name'];
      case 1:
        return <String>['birthMonth', 'birthYear'];
      case 2:
        return <String>['breed'];
      case 3:
        return <String>['sex'];
      case 4:
        return <String>['height'];
      case 5:
        return <String>['city', 'state'];
      case 6:
        return <String>[];
      default:
        return <String>[];
    }
  }
}

final onboardingScreenPresenterProvider =
    Provider.autoDispose<OnboardingScreenPresenter>((ref) {
      final presenter = OnboardingScreenPresenter(
        ref.watch(profilingServiceProvider),
        ref.watch(fileStorageServiceProvider),
        ref.watch(fileStorageDriverProvider),
        ref.watch(mediaPickerDriverProvider),
        ref.watch(navigationDriverProvider),
        ref.watch(cacheDriverProvider),
      );
      ref.onDispose(presenter.dispose);
      return presenter;
    });
