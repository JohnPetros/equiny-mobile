import 'package:equiny/core/auth/interfaces/auth_service.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class SignUpScreenPresenter {
  final AuthService _authService;
  final NavigationDriver _navigationDriver;
  final CacheDriver _cacheDriver;
  final ProfilingService _profilingService;

  final Signal<FormGroup> form = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<bool> isLoading = signal(false);
  final Signal<String?> generalError = signal(null);
  final Signal<bool> isPasswordVisible = signal(false);
  final Signal<bool> isPasswordConfirmationVisible = signal(false);
  final Signal<bool> submitAttempted = signal(false);

  late final ReadonlySignal<bool> canSubmit;
  late final ReadonlySignal<bool> hasAnyFieldError;

  SignUpScreenPresenter(
    this._authService,
    this._profilingService,
    this._navigationDriver,
    this._cacheDriver,
  ) {
    form.value = buildForm();
    canSubmit = computed(() => form.value.valid && !isLoading.value);
    hasAnyFieldError = computed(() {
      if (!submitAttempted.value) {
        return false;
      }
      return form.value.controls.values.any((AbstractControl<Object?> control) {
        return control.invalid;
      });
    });
  }

  void applyServerFieldErrors(RestResponse response) {
    final String message = response.errorMessage.toLowerCase();
    if (message.contains('email')) {
      form.value.control('email').setErrors(<String, Object>{
        'server': 'E-mail ja esta em uso.',
      });
      return;
    }
    generalError.value = response.errorMessage;
  }

  FormGroup buildForm() {
    return FormGroup(
      <String, AbstractControl<Object?>>{
        'name': FormControl<String>(
          validators: <Validator<dynamic>>[
            Validators.required,
            Validators.minLength(3),
            Validators.maxLength(80),
          ],
        ),
        'email': FormControl<String>(
          validators: <Validator<dynamic>>[
            Validators.required,
            Validators.email,
            Validators.maxLength(120),
          ],
        ),
        'password': FormControl<String>(
          validators: <Validator<dynamic>>[
            Validators.required,
            Validators.minLength(8),
            Validators.maxLength(32),
          ],
        ),
        'passwordConfirmation': FormControl<String>(
          validators: <Validator<dynamic>>[
            Validators.required,
            Validators.minLength(8),
            Validators.maxLength(32),
          ],
        ),
      },
      validators: <Validator<dynamic>>[
        Validators.mustMatch('password', 'passwordConfirmation'),
      ],
    );
  }

  void goToSignIn() {
    _navigationDriver.goTo(Routes.signIn);
  }

  void normalizeBeforeSubmit() {
    final String normalizedName =
        (form.value.control('name').value as String? ?? '').trim();
    final String normalizedEmail =
        (form.value.control('email').value as String? ?? '')
            .trim()
            .toLowerCase();
    form.value.control('name').updateValue(normalizedName);
    form.value.control('email').updateValue(normalizedEmail);
  }

  Future<void> submit() async {
    submitAttempted.value = true;
    generalError.value = null;

    form.value.markAllAsTouched();
    if (!form.value.valid || isLoading.value) {
      return;
    }

    normalizeBeforeSubmit();
    isLoading.value = true;

    final response = await _authService.signUp(
      ownerName: form.value.control('name').value as String,
      accountEmail: form.value.control('email').value as String,
      accountPassword: form.value.control('password').value as String,
    );

    if (response.isFailure) {
      isLoading.value = false;
      applyServerFieldErrors(response);
      return;
    }

    _cacheDriver.set(CacheKeys.authToken, response.body.accessToken);

    final ownerResponse = await _profilingService.fetchOwner();
    if (ownerResponse.isFailure) {
      isLoading.value = false;
      generalError.value = ownerResponse.errorMessage;
      return;
    }

    final bool hasCompletedOnboarding =
        ownerResponse.body.hasCompletedOnboarding;

    _cacheDriver.set(
      CacheKeys.onboardingCompleted,
      hasCompletedOnboarding.toString(),
    );
    isLoading.value = false;
    _navigationDriver.goTo(
      hasCompletedOnboarding ? Routes.home : Routes.onboarding,
    );
  }

  void togglePasswordConfirmationVisibility() {
    isPasswordConfirmationVisible.value = !isPasswordConfirmationVisible.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}

final signUpScreenPresenterProvider =
    Provider.autoDispose<SignUpScreenPresenter>((ref) {
      return SignUpScreenPresenter(
        ref.watch(authServiceProvider),
        ref.watch(profilingServiceProvider),
        ref.watch(navigationDriverProvider),
        ref.watch(cacheDriverProvider),
      );
    });
