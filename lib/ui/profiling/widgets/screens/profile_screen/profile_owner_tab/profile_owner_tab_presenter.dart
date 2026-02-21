import 'dart:async';
import 'dart:io';

import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/drivers/media-picker-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class ProfileOwnerTabPresenter {
  final ProfilingService _profilingService;
  final FileStorageService _fileStorageService;
  final FileStorageDriver _fileStorageDriver;
  final MediaPickerDriver _mediaPickerDriver;
  final ProfileOwnerFormSectionPresenter _formSectionPresenter;

  final Signal<FormGroup> ownerForm = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<bool> isLoadingOwner = signal(false);
  final Signal<bool> isSyncingOwner = signal(false);
  final Signal<bool> isUploadingAvatar = signal(false);
  final Signal<String?> generalError = signal(null);
  final Signal<String?> avatarError = signal(null);
  final Signal<String?> ownerAvatarUrl = signal(null);
  final Signal<DateTime?> lastSyncAt = signal(null);
  final Signal<bool> _isHydratingForm = signal(false);
  OwnerDto? _owner;
  String _lastSyncedSignature = '';
  StreamSubscription<Object?>? _ownerFormSub;
  Timer? _autosaveDebounce;

  late final ReadonlySignal<bool> isOwnerFormValid;
  late final ReadonlySignal<bool> hasPendingChanges;

  ProfileOwnerTabPresenter(
    this._profilingService,
    this._fileStorageService,
    this._fileStorageDriver,
    this._mediaPickerDriver,
    this._formSectionPresenter,
  ) {
    ownerForm.value = _formSectionPresenter.buildForm();
    isOwnerFormValid = computed(() => _isOwnerFormValidNow());
    hasPendingChanges = computed(() => _hasPendingChangesNow());
  }

  void init() {
    startOwnerAutosaveListener();
    unawaited(loadOwner());
  }

  void dispose() {
    _ownerFormSub?.cancel();
    _autosaveDebounce?.cancel();
  }

  Future<void> loadOwner() async {
    isLoadingOwner.value = true;
    generalError.value = null;

    try {
      final response = await _profilingService.fetchOwner();
      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      _owner = response.body;
      _isHydratingForm.value = true;
      ownerForm.value.patchValue(
        <String, Object?>{
          'name': _owner?.name ?? '',
          'email': _owner?.email ?? '',
          'phone': _owner?.phone ?? '',
          'bio': _owner?.bio ?? '',
        },
        emitEvent: false,
        updateParent: false,
      );
      _isHydratingForm.value = false;

      ownerAvatarUrl.value = _resolveAvatarUrl(_owner?.avatar);

      print('ownerAvatarUrl: $ownerAvatarUrl.value');

      _lastSyncedSignature = _buildOwnerSignature();
    } catch (_) {
      generalError.value = 'Erro inesperado ao carregar os dados do dono.';
    } finally {
      isLoadingOwner.value = false;
    }
  }

  void startOwnerAutosaveListener() {
    _ownerFormSub?.cancel();
    _ownerFormSub = ownerForm.value.valueChanges.listen((_) {
      if (_isHydratingForm.value) {
        return;
      }

      _autosaveDebounce?.cancel();
      _autosaveDebounce = Timer(
        const Duration(milliseconds: 600),
        () => unawaited(syncOwnerPatch()),
      );
    });
  }

  Future<void> syncOwnerPatch() async {
    if (_owner == null || isSyncingOwner.value || isUploadingAvatar.value) {
      return;
    }

    if (!_isOwnerFormValidNow()) {
      return;
    }

    if (!_hasPendingChangesNow()) {
      return;
    }

    isSyncingOwner.value = true;
    generalError.value = null;

    try {
      final OwnerDto ownerToSync = _buildOwnerPatch();
      final response = await _profilingService.updateOwner(owner: ownerToSync);

      if (response.isFailure) {
        generalError.value = response.errorMessage;
        return;
      }

      final OwnerDto previousOwner = _owner!;
      _owner = OwnerDto(
        id: response.body.id ?? previousOwner.id,
        name: response.body.name,
        email: response.body.email,
        accountId: response.body.accountId,
        phone: response.body.phone?.isEmpty ?? false
            ? (ownerForm.value.control('phone').value as String? ?? '')
            : response.body.phone,
        bio: response.body.bio?.isEmpty ?? false
            ? (ownerForm.value.control('bio').value as String? ?? '')
            : response.body.bio,
        hasCompletedOnboarding: response.body.hasCompletedOnboarding,
        avatar: _resolveAvatar(response.body.avatar, previousOwner.avatar),
      );
      ownerAvatarUrl.value = _resolveAvatarUrl(_owner?.avatar);
      _lastSyncedSignature = _buildOwnerSignature();
      lastSyncAt.value = DateTime.now();
    } catch (_) {
      generalError.value = 'Erro inesperado ao sincronizar dados do dono.';
    } finally {
      isSyncingOwner.value = false;
    }
  }

  OwnerDto _buildOwnerPatch() {
    final OwnerDto owner = _owner!;
    final String normalizedName = normalizeBeforeSync(
      ownerForm.value.control('name').value as String? ?? '',
    );
    final String normalizedEmail = normalizeBeforeSync(
      ownerForm.value.control('email').value as String? ?? owner.email,
    );
    final String normalizedPhone = normalizeBeforeSync(
      ownerForm.value.control('phone').value as String? ?? owner.phone ?? '',
    );
    final String normalizedBio = normalizeBeforeSync(
      ownerForm.value.control('bio').value as String? ?? owner.bio ?? '',
    );

    return OwnerDto(
      id: owner.id,
      name: normalizedName,
      email: normalizedEmail,
      accountId: owner.accountId,
      phone: normalizedPhone,
      bio: normalizedBio,
      hasCompletedOnboarding: owner.hasCompletedOnboarding,
      avatar: owner.avatar,
    );
  }

  Future<void> pickAndUploadAvatar() async {
    await _pickAndUploadAvatar();
  }

  Future<void> replaceAvatar() async {
    await _pickAndUploadAvatar();
  }

  Future<void> _pickAndUploadAvatar() async {
    if (isUploadingAvatar.value) {
      return;
    }

    final OwnerDto? owner = _owner;
    final String ownerId = owner?.id ?? '';
    if (owner == null || ownerId.isEmpty) {
      avatarError.value =
          'Nao foi possivel identificar o dono para enviar avatar.';
      return;
    }

    isUploadingAvatar.value = true;
    avatarError.value = null;

    try {
      final List<File> files = await _mediaPickerDriver.pickImages(
        maxImages: 1,
      );
      if (files.isEmpty) {
        return;
      }

      final File file = files.first;
      final String fileName = _resolveFileName(file);

      final uploadUrlsResponse = await _fileStorageService
          .generateUploadUrlForOwnerAvatar(
            ownerId: ownerId,
            fileName: fileName,
          );

      if (uploadUrlsResponse.isFailure) {
        avatarError.value = uploadUrlsResponse.errorMessage;
        return;
      }

      final uploadUrl = uploadUrlsResponse.body;
      await _fileStorageDriver.uploadFile(file, uploadUrl);

      final String avatarPath = uploadUrl.filePath;
      final ImageDto? previousAvatar = _owner?.avatar;
      final bool hasSynced = await syncOwnerAvatar(avatarPath);

      if (!hasSynced) {
        ownerAvatarUrl.value = _resolveAvatarUrl(previousAvatar);
      }
    } on UnsupportedError {
      avatarError.value =
          'Selecao de imagem nao suportada nesta plataforma/dispositivo.';
    } catch (error) {
      avatarError.value = error.toString();
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> removeAvatar() async {
    if (isUploadingAvatar.value || isSyncingOwner.value || _owner == null) {
      return;
    }

    avatarError.value = null;
    final ImageDto? previousAvatar = _owner?.avatar;
    final bool hasSynced = await syncOwnerAvatar(null);

    if (!hasSynced) {
      ownerAvatarUrl.value = _resolveAvatarUrl(previousAvatar);
    }
  }

  Future<bool> syncOwnerAvatar(String? avatarPath) async {
    final OwnerDto? owner = _owner;
    if (owner == null || isSyncingOwner.value) {
      return false;
    }

    isSyncingOwner.value = true;
    avatarError.value = null;

    try {
      final OwnerDto ownerToSync = _buildOwnerPatch().copyWithAvatar(
        avatarPath,
      );
      final response = await _profilingService.updateOwner(owner: ownerToSync);

      if (response.isFailure) {
        avatarError.value = response.errorMessage;
        return false;
      }

      final OwnerDto previousOwner = _owner!;
      _owner = OwnerDto(
        id: response.body.id ?? previousOwner.id,
        name: response.body.name,
        email: response.body.email,
        accountId: response.body.accountId,
        phone: response.body.phone?.isEmpty ?? false
            ? (ownerForm.value.control('phone').value as String? ?? '')
            : response.body.phone,
        bio: response.body.bio?.isEmpty ?? false
            ? (ownerForm.value.control('bio').value as String? ?? '')
            : response.body.bio,
        hasCompletedOnboarding: response.body.hasCompletedOnboarding,
        avatar: _resolveAvatar(response.body.avatar, owner.avatar),
      );

      ownerAvatarUrl.value = _resolveAvatarUrl(_owner?.avatar);
      _lastSyncedSignature = _buildOwnerSignature();
      lastSyncAt.value = DateTime.now();
      return true;
    } catch (_) {
      avatarError.value = 'Erro inesperado ao sincronizar avatar do dono.';
      return false;
    } finally {
      isSyncingOwner.value = false;
    }
  }

  String _resolveFileName(File file) {
    final List<String> pathSegments = file.uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }

    final List<String> splitBySlash = file.path.split('/');
    if (splitBySlash.isNotEmpty) {
      return splitBySlash.last;
    }

    return 'owner-avatar.jpg';
  }

  ImageDto? _resolveAvatar(ImageDto? candidate, ImageDto? fallback) {
    final String candidateKey = (candidate?.key ?? '').trim();
    if (candidateKey.isNotEmpty) {
      return candidate;
    }

    final String fallbackKey = (fallback?.key ?? '').trim();
    if (fallbackKey.isNotEmpty) {
      return fallback;
    }

    return null;
  }

  String? _resolveAvatarUrl(ImageDto? avatar) {
    final String normalizedPath = (avatar?.key ?? '').trim();
    if (normalizedPath.isEmpty) {
      return null;
    }

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      return normalizedPath;
    }

    return _fileStorageDriver.getFileUrl(normalizedPath);
  }

  String normalizeBeforeSync(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _buildOwnerSignature() {
    final String name = normalizeBeforeSync(
      ownerForm.value.control('name').value as String? ?? '',
    );
    final String email = normalizeBeforeSync(
      ownerForm.value.control('email').value as String? ?? '',
    );
    final String phoneRaw = normalizeBeforeSync(
      ownerForm.value.control('phone').value as String? ?? '',
    );
    final String bio = normalizeBeforeSync(
      ownerForm.value.control('bio').value as String? ?? '',
    );
    return <String>[name, email, phoneRaw, bio].join('|');
  }

  bool _isOwnerFormValidNow() {
    final FormGroup form = ownerForm.value;
    form.updateValueAndValidity();
    return form.valid;
  }

  bool _hasPendingChangesNow() {
    return _lastSyncedSignature != _buildOwnerSignature();
  }

  void clearError() {
    generalError.value = null;
  }
}

final profileOwnerTabPresenterProvider =
    Provider.autoDispose<ProfileOwnerTabPresenter>((ref) {
      final presenter = ProfileOwnerTabPresenter(
        ref.watch(profilingServiceProvider),
        ref.watch(fileStorageServiceProvider),
        ref.watch(fileStorageDriverProvider),
        ref.watch(mediaPickerDriverProvider),
        ProfileOwnerFormSectionPresenter(),
      );
      presenter.init();
      ref.onDispose(presenter.dispose);
      return presenter;
    });

extension on OwnerDto {
  OwnerDto copyWithAvatar(String? avatar) {
    final String normalizedAvatarKey = (avatar ?? '').trim();
    final ImageDto? avatarImage = normalizedAvatarKey.isEmpty
        ? null
        : ImageDto(
            key: normalizedAvatarKey,
            name: this.avatar?.name ?? 'owner-avatar.jpg',
          );

    return OwnerDto(
      id: id,
      name: name,
      email: email,
      accountId: accountId,
      hasCompletedOnboarding: hasCompletedOnboarding,
      avatar: avatarImage,
      phone: phone,
      bio: bio,
    );
  }
}
