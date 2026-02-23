import 'package:equiny/core/auth/interfaces/auth_service.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/shared/providers/auth_state_provider.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fakers/auth/jwt_dto_faker.dart';

class MockAuthService extends Mock implements AuthService {}

class MockProfilingService extends Mock implements ProfilingService {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockCacheDriver extends Mock implements CacheDriver {}

void main() {
  late MockAuthService authService;
  late MockProfilingService profilingService;
  late MockNavigationDriver navigationDriver;
  late MockCacheDriver cacheDriver;
  late AuthStateNotifier authStateNotifier;
  late SignUpScreenPresenter presenter;

  setUp(() {
    authService = MockAuthService();
    profilingService = MockProfilingService();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    authStateNotifier = AuthStateNotifier(false);
    presenter = SignUpScreenPresenter(
      authService,
      profilingService,
      navigationDriver,
      cacheDriver,
      authStateNotifier,
    );

    when(() => cacheDriver.set(any(), any())).thenAnswer((_) async {});
  });

  group('SignUpScreenPresenter', () {
    test('should initialize with invalid form and default state', () {
      expect(presenter.form.value.valid, isFalse);
      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.submitAttempted.value, isFalse);
      expect(presenter.canSubmit.value, isFalse);
      expect(presenter.hasAnyFieldError.value, isFalse);
    });

    test('should navigate to sign in when goToSignIn is called', () {
      presenter.goToSignIn();

      verify(() => navigationDriver.goTo(Routes.signIn)).called(1);
    });

    test('should toggle password visibility state', () {
      expect(presenter.isPasswordVisible.value, isFalse);

      presenter.togglePasswordVisibility();
      expect(presenter.isPasswordVisible.value, isTrue);

      presenter.togglePasswordVisibility();
      expect(presenter.isPasswordVisible.value, isFalse);
    });

    test('should toggle password confirmation visibility state', () {
      expect(presenter.isPasswordConfirmationVisible.value, isFalse);

      presenter.togglePasswordConfirmationVisibility();
      expect(presenter.isPasswordConfirmationVisible.value, isTrue);

      presenter.togglePasswordConfirmationVisibility();
      expect(presenter.isPasswordConfirmationVisible.value, isFalse);
    });

    test('should normalize name and email before submit', () {
      presenter.form.value.control('name').value = '  John Doe  ';
      presenter.form.value.control('email').value = '  JOHN@MAIL.COM  ';

      presenter.normalizeBeforeSubmit();

      expect(presenter.form.value.control('name').value, 'John Doe');
      expect(presenter.form.value.control('email').value, 'john@mail.com');
    });

    test(
      'should apply email server error to email field when message contains email',
      () {
        presenter.applyServerFieldErrors(
          RestResponse<void>(
            statusCode: 400,
            errorMessage: 'Email already exists',
          ),
        );

        expect(
          presenter.form.value.control('email').errors.containsKey('server'),
          isTrue,
        );
        expect(presenter.generalError.value, isNull);
      },
    );

    test(
      'should set general error when server error does not contain email',
      () {
        presenter.applyServerFieldErrors(
          RestResponse<void>(
            statusCode: 400,
            errorMessage: 'Unexpected server error',
          ),
        );

        expect(presenter.generalError.value, 'Unexpected server error');
      },
    );

    test('should not call signUp when form is invalid', () async {
      await presenter.submit();

      expect(presenter.submitAttempted.value, isTrue);
      verifyNever(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      );
    });

    test('should complete signup and navigate when service succeeds', () async {
      presenter.form.value.control('name').value = '  John Doe  ';
      presenter.form.value.control('email').value = 'JOHN@MAIL.COM';
      presenter.form.value.control('password').value = 'password123';
      presenter.form.value.control('passwordConfirmation').value =
          'password123';

      when(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      ).thenAnswer(
        (_) async =>
            RestResponse(body: JwtDtoFaker.fakeDto(accessToken: 'token-123')),
      );
      when(() => profilingService.fetchOwner()).thenAnswer(
        (_) async => RestResponse<OwnerDto>(
          body: const OwnerDto(
            id: 'owner-1',
            name: 'John Doe',
            email: 'john@mail.com',
            accountId: 'acc-1',
            phone: '',
            bio: '',
            hasCompletedOnboarding: false,
          ),
        ),
      );

      await presenter.submit();

      verify(
        () => authService.signUp(
          ownerName: 'John Doe',
          accountEmail: 'john@mail.com',
          accountPassword: 'password123',
        ),
      ).called(1);
      verify(() => profilingService.fetchOwner()).called(1);
      verify(
        () => cacheDriver.set(CacheKeys.accessToken, 'token-123'),
      ).called(1);
      verify(
        () => cacheDriver.set(CacheKeys.onboardingCompleted, 'false'),
      ).called(1);
      verify(() => navigationDriver.goTo(Routes.onboarding)).called(1);
      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, isNull);
    });

    test('should navigate home when onboarding is already completed', () async {
      presenter.form.value.control('name').value = 'John Doe';
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';
      presenter.form.value.control('passwordConfirmation').value =
          'password123';

      when(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      ).thenAnswer(
        (_) async =>
            RestResponse(body: JwtDtoFaker.fakeDto(accessToken: 'token-456')),
      );
      when(() => profilingService.fetchOwner()).thenAnswer(
        (_) async => RestResponse<OwnerDto>(
          body: const OwnerDto(
            id: 'owner-1',
            name: 'John Doe',
            email: 'john@mail.com',
            accountId: 'acc-1',
            phone: '',
            bio: '',
            hasCompletedOnboarding: true,
          ),
        ),
      );

      await presenter.submit();

      verify(() => profilingService.fetchOwner()).called(1);
      verify(
        () => cacheDriver.set(CacheKeys.accessToken, 'token-456'),
      ).called(1);
      verify(
        () => cacheDriver.set(CacheKeys.onboardingCompleted, 'true'),
      ).called(1);
      verify(() => navigationDriver.goTo(Routes.home)).called(1);
      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, isNull);
    });

    test('should set errors and stop flow when signup fails', () async {
      presenter.form.value.control('name').value = 'John Doe';
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';
      presenter.form.value.control('passwordConfirmation').value =
          'password123';

      when(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      ).thenAnswer(
        (_) async => RestResponse<JwtDto>(
          statusCode: 400,
          errorMessage: 'email already exists',
        ),
      );

      await presenter.submit();

      expect(presenter.isLoading.value, isFalse);
      expect(
        presenter.form.value.control('email').errors.containsKey('server'),
        isTrue,
      );
      verifyNever(() => cacheDriver.set(any(), any()));
      verifyNever(() => navigationDriver.goTo(Routes.onboarding));
      verifyNever(() => profilingService.fetchOwner());
    });

    test('should not submit when already loading', () async {
      presenter.form.value.control('name').value = 'John Doe';
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';
      presenter.form.value.control('passwordConfirmation').value =
          'password123';
      presenter.isLoading.value = true;

      await presenter.submit();

      verifyNever(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      );
    });
  });
}
