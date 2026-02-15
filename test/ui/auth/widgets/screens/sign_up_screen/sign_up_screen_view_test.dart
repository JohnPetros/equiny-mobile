import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class MockSignUpScreenPresenter extends Mock implements SignUpScreenPresenter {}

void main() {
  late MockSignUpScreenPresenter presenter;

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        signUpScreenPresenterProvider.overrideWithValue(presenter),
      ],
      child: const MaterialApp(home: SignUpScreenView()),
    );
  }

  setUp(() {
    presenter = MockSignUpScreenPresenter();

    when(() => presenter.form).thenReturn(
      signal(
        FormGroup(<String, AbstractControl<Object?>>{
          'name': FormControl<String>(),
          'email': FormControl<String>(),
          'password': FormControl<String>(),
          'passwordConfirmation': FormControl<String>(),
        }),
      ),
    );
    when(() => presenter.submitAttempted).thenReturn(signal(false));
    when(() => presenter.isPasswordVisible).thenReturn(signal(false));
    when(
      () => presenter.isPasswordConfirmationVisible,
    ).thenReturn(signal(false));
    when(() => presenter.isLoading).thenReturn(signal(false));
    when(() => presenter.generalError).thenReturn(signal(null));
    when(() => presenter.submit()).thenAnswer((_) async {});
    when(() => presenter.goToSignIn()).thenReturn(null);
    when(() => presenter.togglePasswordVisibility()).thenReturn(null);
    when(
      () => presenter.togglePasswordConfirmationVisibility(),
    ).thenReturn(null);
  });

  group('SignUpScreenView', () {
    testWidgets('should render sign up base content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Criar conta'), findsNWidgets(2));
      expect(find.text('Crie sua conta para comecar.'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Nome do dono'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar senha'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render general error when presenter has one', (
      WidgetTester tester,
    ) async {
      when(() => presenter.generalError).thenReturn(signal('Erro inesperado'));

      await tester.pumpWidget(createWidget());

      expect(find.text('Erro inesperado'), findsOneWidget);
    });

    testWidgets('should call submit when create account button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();

      verify(() => presenter.submit()).called(1);
    });

    testWidgets('should call goToSignIn when entrar is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.ensureVisible(find.text('Entrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      verify(() => presenter.goToSignIn()).called(1);
    });

    testWidgets('should call toggle visibility methods when icons are tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      final Finder visibilityButtons = find.byIcon(Icons.visibility);
      await tester.tap(visibilityButtons.first);
      await tester.tap(visibilityButtons.last);
      await tester.pump();

      verify(() => presenter.togglePasswordVisibility()).called(1);
      verify(() => presenter.togglePasswordConfirmationVisibility()).called(1);
    });
  });
}
