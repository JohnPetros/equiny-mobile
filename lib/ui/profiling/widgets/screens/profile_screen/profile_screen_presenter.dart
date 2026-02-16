import 'dart:async';

import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/drivers/media-picker-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

enum ProfileTab { horse, owner }

class ProfileScreenPresenter {
  static const int maxImages = 6;

  final ProfilingService _profilingService;
  final FileStorageService _fileStorageService;
  final MediaPickerDriver _mediaPickerDriver;
  final NavigationDriver _navigationDriver;

  final Signal<ProfileTab> activeTab = signal(ProfileTab.horse);
  final Signal<FormGroup> horseForm = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<List<ImageDto>> horseImages = signal(<ImageDto>[]);
  final Signal<bool> isLoadingInitialData = signal(false);
  final Signal<bool> isSyncingHorse = signal(false);
  final Signal<bool> isSyncingGallery = signal(false);
  final Signal<bool> isUploadingImages = signal(false);
  final Signal<bool> isHorseActive = signal(false);
  final Signal<String?> generalError = signal(null);
  final Signal<Map<String, String>> fieldErrorsByKey = signal(
    <String, String>{},
  );
  final Signal<DateTime?> lastSyncAt = signal(null);

  final Signal<String?> _horseId = signal(null);
  final Signal<bool> _isHydratingForm = signal(false);

  StreamSubscription<Object?>? _horseFormSub;
  Timer? _autosaveDebounce;

  late final ReadonlySignal<bool> isHorseTab;
  late final ReadonlySignal<int> remainingImagesCount;
  late final ReadonlySignal<bool> canActivateHorse;
  late final ReadonlySignal<List<String>> feedReadinessChecklist;

  ProfileScreenPresenter(
    this._profilingService,
    this._fileStorageService,
    this._mediaPickerDriver,
    this._navigationDriver,
  ) {
    horseForm.value = _buildHorseForm();
    isHorseTab = computed(() => activeTab.value == ProfileTab.horse);
    remainingImagesCount = computed(() => maxImages - horseImages.value.length);
    feedReadinessChecklist = computed(_buildFeedChecklist);
    canActivateHorse = computed(() => feedReadinessChecklist.value.isEmpty);
  }

  void init() {
    startHorseAutosaveListener();
    unawaited(loadHorseProfile());
  }

  void dispose() {
    _horseFormSub?.cancel();
    _autosaveDebounce?.cancel();
  }

  FormGroup _buildHorseForm() {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
      'birthMonth': FormControl<int>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(1),
          Validators.max(12),
        ],
      ),
      'birthYear': FormControl<int>(validators: <Validator<dynamic>>[]),
      'breed': FormControl<String>(),
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
      'description': FormControl<String>(),
    });
  }

  Future<void> loadHorseProfile() async {
    isLoadingInitialData.value = true;
    generalError.value = null;

    try {
      final horsesResponse = await _profilingService.fetchOwnerHorses();
      if (horsesResponse.isFailure) {
        generalError.value = horsesResponse.errorMessage;
        return;
      }

      final List<HorseDto> horses = horsesResponse.body;
      if (horses.isEmpty) {
        generalError.value = 'Nenhum cavalo encontrado para este perfil.';
        return;
      }

      final HorseDto horse = horses.first;
      _horseId.value = horse.id;
      _hydrateHorseForm(horse);
      isHorseActive.value = horse.isActive;

      if ((horse.id ?? '').isNotEmpty) {
        final galleryResponse = await _profilingService.fetchHorseGallery(
          horseId: horse.id!,
        );
        if (galleryResponse.isSuccessful) {
          horseImages.value = galleryResponse.body.images;
        }
      }
    } catch (_) {
      generalError.value = 'Erro inesperado ao carregar perfil do cavalo.';
    } finally {
      isLoadingInitialData.value = false;
    }
  }

  void _hydrateHorseForm(HorseDto horse) {
    _isHydratingForm.value = true;
    horseForm.value.patchValue(
      <String, Object?>{
        'name': horse.name,
        'birthMonth': horse.birthMonth,
        'birthYear': horse.birthYear,
        'breed': horse.breed,
        'sex': horse.sex,
        'height': horse.height,
        'city': horse.location.city,
        'state': horse.location.state,
        'description': horse.description,
      },
      updateParent: false,
      emitEvent: false,
    );
    _isHydratingForm.value = false;
  }

  void switchTab(ProfileTab tab) {
    activeTab.value = tab;
  }

  void startHorseAutosaveListener() {
    _horseFormSub?.cancel();
    _horseFormSub = horseForm.value.valueChanges.listen((_) {
      if (_isHydratingForm.value) {
        return;
      }
      _autosaveDebounce?.cancel();
      _autosaveDebounce = Timer(
        const Duration(milliseconds: 600),
        () => unawaited(syncHorsePatch()),
      );
    });
  }

  Future<void> syncHorsePatch() async {
    final String horseId = _horseId.value ?? '';
    if (horseId.isEmpty || horseForm.value.invalid || isSyncingHorse.value) {
      return;
    }

    isSyncingHorse.value = true;
    generalError.value = null;

    try {
      final HorseDto horse = _buildHorseFromForm(horseId: horseId);
      final response = await _profilingService.updateHorse(horse: horse);
      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      _horseId.value = response.body.id;
      isHorseActive.value = response.body.isActive;
      lastSyncAt.value = DateTime.now();
      fieldErrorsByKey.value = <String, String>{};
    } catch (_) {
      generalError.value = 'Erro inesperado ao sincronizar dados do cavalo.';
    } finally {
      isSyncingHorse.value = false;
    }
  }

  HorseDto _buildHorseFromForm({required String horseId}) {
    return HorseDto(
      id: horseId,
      name: (horseForm.value.control('name').value as String? ?? '').trim(),
      birthMonth: horseForm.value.control('birthMonth').value as int? ?? 0,
      birthYear: horseForm.value.control('birthYear').value as int? ?? 0,
      breed: (horseForm.value.control('breed').value as String? ?? '').trim(),
      sex: (horseForm.value.control('sex').value as String? ?? '').trim(),
      height: horseForm.value.control('height').value as double? ?? 0,
      location: LocationDto(
        city: (horseForm.value.control('city').value as String? ?? '').trim(),
        state: (horseForm.value.control('state').value as String? ?? '')
            .trim()
            .toUpperCase(),
      ),
      description:
          (horseForm.value.control('description').value as String? ?? '')
              .trim(),
      isActive: isHorseActive.value,
    );
  }

  Future<void> pickAndUploadImages() async {
    if (isUploadingImages.value || remainingImagesCount.value <= 0) {
      return;
    }

    generalError.value = null;
    isUploadingImages.value = true;

    try {
      final files = await _mediaPickerDriver.pickImages(
        maxImages: remainingImagesCount.value,
      );
      if (files.isEmpty) {
        return;
      }

      final response = await _fileStorageService.uploadImageFiles(files: files);
      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      horseImages.value = <ImageDto>[...horseImages.value, ...response.body];
      await syncGallery();
    } on UnsupportedError {
      generalError.value =
          'Selecao de imagem nao suportada nesta plataforma/dispositivo.';
    } catch (_) {
      generalError.value = 'Erro inesperado ao enviar imagens.';
    } finally {
      isUploadingImages.value = false;
    }
  }

  Future<void> retryImageUpload() async {
    await pickAndUploadImages();
  }

  Future<void> removeImage(ImageDto image) async {
    horseImages.value = horseImages.value
        .where((ImageDto currentImage) => currentImage.key != image.key)
        .toList();
    await syncGallery();
  }

  Future<void> setPrimaryImage(ImageDto image) async {
    final List<ImageDto> reordered = <ImageDto>[image];
    reordered.addAll(
      horseImages.value.where(
        (ImageDto currentImage) => currentImage.key != image.key,
      ),
    );
    horseImages.value = reordered;
    await syncGallery();
  }

  Future<void> syncGallery() async {
    final String horseId = _horseId.value ?? '';
    if (horseId.isEmpty || isSyncingGallery.value) {
      return;
    }

    isSyncingGallery.value = true;
    try {
      final response = await _profilingService.updateHorseGallery(
        horseId: horseId,
        gallery: GalleryDto(horseId: horseId, images: horseImages.value),
      );

      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      horseImages.value = response.body.images;
      lastSyncAt.value = DateTime.now();
    } catch (_) {
      generalError.value = 'Erro inesperado ao sincronizar galeria.';
    } finally {
      isSyncingGallery.value = false;
    }
  }

  Future<void> toggleHorseActive(bool value) async {
    generalError.value = null;
    if (value && !canActivateHorse.value) {
      generalError.value =
          'Seu cavalo ainda nao esta pronto para aparecer no feed.';
      return;
    }

    isHorseActive.value = value;
    await syncHorsePatch();
  }

  void discardLocalErrors() {
    generalError.value = null;
    fieldErrorsByKey.value = <String, String>{};
  }

  void goBack() {
    if (_navigationDriver.canGoBack()) {
      _navigationDriver.goBack();
    }
  }

  List<String> _buildFeedChecklist() {
    final List<String> pending = <String>[];
    final FormGroup form = horseForm.value;

    if ((form.control('name').value as String? ?? '').trim().isEmpty) {
      pending.add('Preencher nome do cavalo');
    }

    if ((form.control('sex').value as String? ?? '').trim().isEmpty) {
      pending.add('Definir sexo');
    }

    if ((form.control('city').value as String? ?? '').trim().isEmpty ||
        (form.control('state').value as String? ?? '').trim().isEmpty) {
      pending.add('Informar localizacao (cidade/UF)');
    }

    if (horseImages.value.isEmpty) {
      pending.add('Adicionar pelo menos 1 foto');
    }

    return pending;
  }
}

final profileScreenPresenterProvider =
    Provider.autoDispose<ProfileScreenPresenter>((ref) {
      final presenter = ProfileScreenPresenter(
        ref.watch(profilingServiceProvider),
        ref.watch(fileStorageServiceProvider),
        ref.watch(mediaPickerDriverProvider),
        ref.watch(navigationDriverProvider),
      );
      presenter.init();
      ref.onDispose(presenter.dispose);
      return presenter;
    });
