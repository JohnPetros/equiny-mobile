import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class MockSignInScreenPresenter extends Mock implements SignInScreenPresenter {}

void main() {
  late MockSignInScreenPresenter presenter;

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        signInScreenPresenterProvider.overrideWithValue(presenter),
      ],
      child: const MaterialApp(home: SignInScreenView()),
    );
  }

  setUp(() {
    presenter = MockSignInScreenPresenter();

    when(() => presenter.form).thenReturn(
      signal(
        FormGroup(<String, AbstractControl<Object?>>{
          'email': FormControl<String>(),
          'password': FormControl<String>(),
        }),
      ),
    );
    when(() => presenter.submitAttempted).thenReturn(signal(false));
    when(() => presenter.isPasswordVisible).thenReturn(signal(false));
    when(() => presenter.isLoading).thenReturn(signal(false));
    when(() => presenter.generalError).thenReturn(signal(null));
    when(() => presenter.submit()).thenAnswer((_) async {});
    when(() => presenter.goToSignUp()).thenReturn(null);
    when(() => presenter.togglePasswordVisibility()).thenReturn(null);
  });

  group('SignInScreenView', () {
    testWidgets('should render sign in base content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Entrar'), findsNWidgets(2));
      expect(find.text('Acesse sua conta para continuar.'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Não tem uma conta? '), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });

    testWidgets('should render general error when presenter has one', (
      WidgetTester tester,
    ) async {
      when(
        () => presenter.generalError,
      ).thenReturn(signal('Erro de autenticacao'));

      await tester.pumpWidget(createWidget());

      expect(find.text('Erro de autenticacao'), findsOneWidget);
    });

    testWidgets('should call submit when entrar button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      verify(() => presenter.submit()).called(1);
    });

    testWidgets('should call goToSignUp when criar conta is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      verify(() => presenter.goToSignUp()).called(1);
    });

    testWidgets(
      'should call togglePasswordVisibility when visibility icon is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        final Finder visibilityButton = find.byIcon(Icons.visibility);
        expect(visibilityButton, findsOneWidget);

        await tester.tap(visibilityButton);
        await tester.pump();

        verify(() => presenter.togglePasswordVisibility()).called(1);
      },
    );

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      when(() => presenter.isLoading).thenReturn(signal(true));

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('should show email and password input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(ReactiveTextField<String>), findsNWidgets(2));
    });
  });
}
