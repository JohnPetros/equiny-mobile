import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/auth/interfaces/auth_service.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart';
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
  late SignInScreenPresenter presenter;

  setUp(() {
    authService = MockAuthService();
    profilingService = MockProfilingService();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    presenter = SignInScreenPresenter(
      authService,
      profilingService,
      navigationDriver,
      cacheDriver,
      initialEmail: 'test@equiny.com',
      initialPassword: '12345678',
    );

    when(() => cacheDriver.set(any(), any())).thenAnswer((_) async {});
  });

  group('SignInScreenPresenter', () {
    test('should initialize with default form values and state', () {
      expect(presenter.form.value.valid, isTrue);
      expect(presenter.form.value.control('email').value, 'test@equiny.com');
      expect(presenter.form.value.control('password').value, '12345678');
      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.isPasswordVisible.value, isFalse);
      expect(presenter.submitAttempted.value, isFalse);
      expect(presenter.canSubmit.value, isTrue);
      expect(presenter.hasAnyFieldError.value, isFalse);
    });

    test('should navigate to sign up when goToSignUp is called', () {
      presenter.goToSignUp();

      verify(() => navigationDriver.goTo(Routes.signUp)).called(1);
    });

    test('should toggle password visibility state', () {
      expect(presenter.isPasswordVisible.value, isFalse);

      presenter.togglePasswordVisibility();
      expect(presenter.isPasswordVisible.value, isTrue);

      presenter.togglePasswordVisibility();
      expect(presenter.isPasswordVisible.value, isFalse);
    });

    test('should normalize email before submit', () {
      presenter.form.value.control('email').value = '  JOHN@MAIL.COM  ';

      presenter.normalizeBeforeSubmit();

      expect(presenter.form.value.control('email').value, 'john@mail.com');
    });

    test(
      'should apply email/credenciais error to general error when message contains email',
      () {
        presenter.applyServerFieldErrors(
          RestResponse<void>(
            statusCode: 400,
            errorMessage: 'Email invalido ou credenciais incorretas',
          ),
        );

        expect(
          presenter.generalError.value,
          'email invalido ou credenciais incorretas',
        );
      },
    );

    test(
      'should set general error when server error does not contain email/credenciais',
      () {
        presenter.applyServerFieldErrors(
          RestResponse<void>(
            statusCode: 500,
            errorMessage: 'Erro interno do servidor',
          ),
        );

        expect(presenter.generalError.value, 'Erro interno do servidor');
      },
    );

    test('should not call signIn when form is invalid', () async {
      presenter.form.value.control('email').value = '';

      await presenter.submit();

      expect(presenter.submitAttempted.value, isTrue);
      verifyNever(
        () => authService.signIn(
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      );
    });

    test(
      'should complete sign in and navigate to onboarding when not completed',
      () async {
        presenter.form.value.control('email').value = 'JOHN@MAIL.COM';
        presenter.form.value.control('password').value = 'password123';

        when(
          () => authService.signIn(
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
              hasCompletedOnboarding: false,
            ),
          ),
        );

        await presenter.submit();

        verify(
          () => authService.signIn(
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
      },
    );

    test(
      'should complete sign in and navigate to home when onboarding completed',
      () async {
        presenter.form.value.control('email').value = 'john@mail.com';
        presenter.form.value.control('password').value = 'password123';

        when(
          () => authService.signIn(
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
      },
    );

    test('should set general error when sign in fails', () async {
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';

      when(
        () => authService.signIn(
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      ).thenAnswer(
        (_) async => RestResponse<JwtDto>(
          statusCode: 401,
          errorMessage: 'credenciais invalidas',
        ),
      );

      await presenter.submit();

      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, 'credenciais invalidas');
      verifyNever(() => profilingService.fetchOwner());
      verifyNever(() => cacheDriver.set(any(), any()));
      verifyNever(() => navigationDriver.goTo(any()));
    });

    test('should set general error when fetch owner fails', () async {
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';

      when(
        () => authService.signIn(
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      ).thenAnswer(
        (_) async =>
            RestResponse(body: JwtDtoFaker.fakeDto(accessToken: 'token-123')),
      );
      when(() => profilingService.fetchOwner()).thenAnswer(
        (_) async => RestResponse<OwnerDto>(
          statusCode: 500,
          errorMessage: 'Erro ao buscar dados do usuario',
        ),
      );

      await presenter.submit();

      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, 'Erro ao buscar dados do usuario');
      verify(
        () => cacheDriver.set(CacheKeys.accessToken, 'token-123'),
      ).called(1);
      verifyNever(() => cacheDriver.set(CacheKeys.onboardingCompleted, any()));
      verifyNever(() => navigationDriver.goTo(any()));
    });

    test('should not submit when already loading', () async {
      presenter.form.value.control('email').value = 'john@mail.com';
      presenter.form.value.control('password').value = 'password123';
      presenter.isLoading.value = true;

      await presenter.submit();

      verifyNever(
        () => authService.signIn(
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      );
    });

    test('canSubmit should be false when form is invalid', () {
      presenter.form.value.control('email').value = '';

      expect(presenter.canSubmit.value, isFalse);
    });

    test('canSubmit should be false when loading', () {
      presenter.isLoading.value = true;

      expect(presenter.canSubmit.value, isFalse);
    });

    test('hasAnyFieldError should be false when not submit attempted', () {
      presenter.form.value.control('email').value = '';

      expect(presenter.hasAnyFieldError.value, isFalse);
    });

    test(
      'hasAnyFieldError should be true when submit attempted and invalid',
      () {
        presenter.form.value.control('email').value = '';
        presenter.submitAttempted.value = true;

        expect(presenter.hasAnyFieldError.value, isTrue);
      },
    );
  });
}
