import 'package:equiny/core/auth/dtos/account_dto.dart';
import 'package:equiny/core/auth/interfaces/auth_service.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

void main() {
  late MockAuthService authService;
  late MockNavigationDriver navigationDriver;
  late SignUpScreenPresenter presenter;

  setUp(() {
    authService = MockAuthService();
    navigationDriver = MockNavigationDriver();
    presenter = SignUpScreenPresenter(authService, navigationDriver);
  });

  group('SignUpScreenPresenter', () {
    test('should initialize with default state', () {
      expect(presenter.form.value.valid, isFalse);
      expect(presenter.isLoading.value, isFalse);
      expect(presenter.generalError.value, isNull);
      expect(presenter.submitAttempted.value, isFalse);
      expect(presenter.emailVerificationSent.value, isFalse);
      expect(presenter.registeredEmail.value, isNull);
    });

    test('should navigate to sign in when goToSignIn is called', () {
      presenter.goToSignIn();

      verify(() => navigationDriver.goTo(Routes.signIn)).called(1);
    });

    test('should normalize name and email before submit', () {
      presenter.form.value.control('name').value = '  John Doe  ';
      presenter.form.value.control('email').value = '  JOHN@MAIL.COM  ';

      presenter.normalizeBeforeSubmit();

      expect(presenter.form.value.control('name').value, 'John Doe');
      expect(presenter.form.value.control('email').value, 'john@mail.com');
    });

    test('should apply email server error to email field', () {
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
    });

    test('should not call signUp when form is invalid', () async {
      await presenter.submit();

      verifyNever(
        () => authService.signUp(
          ownerName: any(named: 'ownerName'),
          accountEmail: any(named: 'accountEmail'),
          accountPassword: any(named: 'accountPassword'),
        ),
      );
    });

    test(
      'should mark email verification success when sign up succeeds',
      () async {
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
          (_) async => RestResponse<AccountDto>(
            body: AccountDto(
              id: 'acc-1',
              email: 'john@mail.com',
              isVerified: 'false',
            ),
          ),
        );

        await presenter.submit();

        expect(presenter.emailVerificationSent.value, isTrue);
        expect(presenter.registeredEmail.value, 'john@mail.com');
        expect(presenter.generalError.value, isNull);
        verifyNever(() => navigationDriver.goTo(Routes.home));
        verifyNever(() => navigationDriver.goTo(Routes.onboarding));
      },
    );

    test(
      'should set field error and keep success false when sign up fails',
      () async {
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
          (_) async => RestResponse<AccountDto>(
            statusCode: 400,
            errorMessage: 'email already exists',
          ),
        );

        await presenter.submit();

        expect(presenter.emailVerificationSent.value, isFalse);
        expect(
          presenter.form.value.control('email').errors.containsKey('server'),
          isTrue,
        );
      },
    );
  });
}
