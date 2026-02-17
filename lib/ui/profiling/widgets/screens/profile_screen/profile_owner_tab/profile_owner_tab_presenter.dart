import 'dart:async';

import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class ProfileOwnerTabPresenter {
  final ProfilingService _profilingService;
  final ProfileOwnerFormSectionPresenter _formSectionPresenter;

  final Signal<FormGroup> ownerForm = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<bool> isLoadingOwner = signal(false);
  final Signal<bool> isSyncingOwner = signal(false);
  final Signal<String?> generalError = signal(null);
  final Signal<DateTime?> lastSyncAt = signal(null);
  final Signal<bool> _isHydratingForm = signal(false);
  OwnerDto? _owner;
  String _lastSyncedSignature = '';
  StreamSubscription<Object?>? _ownerFormSub;
  Timer? _autosaveDebounce;

  late final ReadonlySignal<bool> isOwnerFormValid;
  late final ReadonlySignal<bool> hasPendingChanges;

  ProfileOwnerTabPresenter(this._profilingService, this._formSectionPresenter) {
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
    if (_owner == null || isSyncingOwner.value) {
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
      );
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
      phone: normalizedPhone.isEmpty ? owner.phone : normalizedPhone,
      bio: normalizedBio,
      hasCompletedOnboarding: owner.hasCompletedOnboarding,
    );
  }

  String normalizeBeforeSync(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _buildOwnerSignature() {
    final OwnerDto owner =
        _owner ??
        const OwnerDto(
          name: '',
          email: '',
          accountId: '',
          phone: '',
          bio: '',
          hasCompletedOnboarding: false,
        );
    final String name = normalizeBeforeSync(
      ownerForm.value.control('name').value as String? ?? '',
    );
    final String email = normalizeBeforeSync(
      ownerForm.value.control('email').value as String? ?? '',
    );
    final String phoneRaw = normalizeBeforeSync(
      ownerForm.value.control('phone').value as String? ?? '',
    );
    final String phone = phoneRaw.isEmpty ? (owner.phone ?? '') : phoneRaw;
    final String bio = normalizeBeforeSync(
      ownerForm.value.control('bio').value as String? ?? '',
    );
    return <String>[name, email, phone, bio].join('|');
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
        ProfileOwnerFormSectionPresenter(),
      );
      presenter.init();
      ref.onDispose(presenter.dispose);
      return presenter;
    });
