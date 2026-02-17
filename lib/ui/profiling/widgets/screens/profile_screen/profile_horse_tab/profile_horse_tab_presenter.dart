import 'dart:async';

import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/drivers/media-picker-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_active_section/profile_horse_active_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/profile_horse_feed_readiness_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/profile_horse_form_section_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class ProfileHorseTabPresenter {
  static const Set<String> _allowedBreeds = <String>{
    'quarto de milha',
    'mangalarga marchador',
    'criolo',
    'puro sangue inglês',
    'arabe',
    'campolina',
    'outra',
  };

  static const int maxImages = 6;

  final ProfilingService _profilingService;
  final FileStorageService _fileStorageService;
  final MediaPickerDriver _mediaPickerDriver;
  final ProfileHorseFormSectionPresenter _formSectionPresenter;
  final ProfileHorseFeedReadinessSectionPresenter _feedReadinessPresenter;
  final ProfileHorseActiveSectionPresenter _activeSectionPresenter;

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
  final Signal<DateTime?> lastSyncAt = signal(null);

  final Signal<String?> _horseId = signal(null);
  final Signal<bool> _isHydratingForm = signal(false);
  String? _lastSyncedHorseSignature;

  StreamSubscription<Object?>? _horseFormSub;
  Timer? _autosaveDebounce;

  late final ReadonlySignal<int> remainingImagesCount;
  late final ReadonlySignal<bool> canActivateHorse;
  late final ReadonlySignal<List<String>> feedReadinessChecklist;

  ProfileHorseTabPresenter(
    this._profilingService,
    this._fileStorageService,
    this._mediaPickerDriver,
    this._formSectionPresenter,
    this._feedReadinessPresenter,
    this._activeSectionPresenter,
  ) {
    horseForm.value = _formSectionPresenter.buildForm();
    remainingImagesCount = computed(() => maxImages - horseImages.value.length);
    feedReadinessChecklist = computed(() {
      return _feedReadinessPresenter.buildChecklist(
        form: horseForm.value,
        images: horseImages.value,
      );
    });
    canActivateHorse = computed(() => feedReadinessChecklist.value.isEmpty);
  }

  void init() {
    _startHorseAutosaveListener();
    unawaited(loadHorseProfile());
  }

  void dispose() {
    _horseFormSub?.cancel();
    _autosaveDebounce?.cancel();
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
    } catch (error) {
      generalError.value = error.toString();
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
        'breed': _normalizeBreed(horse.breed),
        'sex': horse.sex,
        'height': horse.height,
        'city': horse.location.city,
        'state': horse.location.state,
        'description': horse.description,
      },
      updateParent: false,
      emitEvent: false,
    );
    final String horseId = _horseId.value ?? '';
    if (horseId.isNotEmpty) {
      final HorseDto hydratedHorse = _buildHorseFromForm(horseId: horseId);
      _lastSyncedHorseSignature = _buildHorseSignature(hydratedHorse);
    }
    _isHydratingForm.value = false;
  }

  void _startHorseAutosaveListener() {
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
    if (horseId.isEmpty || isSyncingHorse.value) {
      return;
    }

    if (!_validateHorseFormBeforeSync()) {
      return;
    }

    final HorseDto horse = _buildHorseFromForm(horseId: horseId);
    final String nextSignature = _buildHorseSignature(horse);
    if (_lastSyncedHorseSignature == nextSignature) {
      return;
    }

    isSyncingHorse.value = true;
    generalError.value = null;

    try {
      final response = await _profilingService.updateHorse(horse: horse);
      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      _horseId.value = response.body.id;
      isHorseActive.value = response.body.isActive;
      _lastSyncedHorseSignature = nextSignature;
      lastSyncAt.value = DateTime.now();
    } catch (_) {
      generalError.value = 'Erro inesperado ao sincronizar dados do cavalo.';
    } finally {
      isSyncingHorse.value = false;
    }
  }

  bool _validateHorseFormBeforeSync() {
    final FormGroup form = horseForm.value;
    form.markAllAsTouched();
    form.updateValueAndValidity();

    if (form.invalid) {
      generalError.value = 'Preencha os campos obrigatorios antes de salvar.';
      return false;
    }

    return true;
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

  String _normalizeBreed(String? breed) {
    final String normalized = (breed ?? '').trim().toLowerCase();
    if (_allowedBreeds.contains(normalized)) {
      return normalized;
    }

    if (normalized == 'puro sangue ingles') {
      return 'puro sangue inglês';
    }

    return '';
  }

  String _buildHorseSignature(HorseDto horse) {
    return <Object?>[
      horse.id ?? '',
      horse.name,
      horse.birthMonth,
      horse.birthYear,
      horse.breed,
      horse.sex,
      horse.height,
      horse.location.city,
      horse.location.state,
      horse.description,
      horse.isActive,
    ].join('|');
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
    final String? activationError = _activeSectionPresenter.validateActivation(
      isActivating: value,
      canActivate: canActivateHorse.value,
    );
    if (activationError != null) {
      generalError.value = activationError;
      return;
    }

    isHorseActive.value = value;
    await syncHorsePatch();
  }
}

final profileHorseTabPresenterProvider =
    Provider.autoDispose<ProfileHorseTabPresenter>((ref) {
      final presenter = ProfileHorseTabPresenter(
        ref.watch(profilingServiceProvider),
        ref.watch(fileStorageServiceProvider),
        ref.watch(mediaPickerDriverProvider),
        ProfileHorseFormSectionPresenter(),
        ProfileHorseFeedReadinessSectionPresenter(),
        ProfileHorseActiveSectionPresenter(),
      );
      presenter.init();
      ref.onDispose(presenter.dispose);
      return presenter;
    });
