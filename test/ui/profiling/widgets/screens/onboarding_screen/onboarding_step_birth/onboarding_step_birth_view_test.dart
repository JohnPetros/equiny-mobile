import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_birth/onboarding_step_birth_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm({int? month, int? year}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'birthMonth': FormControl<int>(
        value: month,
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'birthYear': FormControl<int>(
        value: year,
        validators: <Validator<dynamic>>[Validators.required],
      ),
    });
  }

  Widget createWidget({
    required FormGroup form,
    required bool submitAttempted,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingStepBirthView(
          form: form,
          submitAttempted: submitAttempted,
          availableMonths: const <int>[1, 2],
          availableYears: const <int>[2020, 2019],
        ),
      ),
    );
  }

  group('OnboardingStepBirthView', () {
    testWidgets('should render month and year fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(month: 1, year: 2020),
          submitAttempted: false,
        ),
      );

      expect(find.text('Mes'), findsOneWidget);
      expect(find.text('Ano'), findsOneWidget);
      expect(find.byType(ReactiveDropdownField<int>), findsNWidgets(2));
    });

    testWidgets('should show validation messages when submitted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: true),
      );

      expect(find.text('Campo obrigatorio.'), findsWidgets);
    });
  });
}
