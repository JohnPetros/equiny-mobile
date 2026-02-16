import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_height/onboarding_step_height_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm({double? height}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'height': FormControl<double>(
        value: height,
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(0.5),
          Validators.max(3.0),
        ],
      ),
    });
  }

  Widget createWidget({
    required FormGroup form,
    required bool submitAttempted,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingStepHeightView(
          form: form,
          submitAttempted: submitAttempted,
        ),
      ),
    );
  }

  group('OnboardingStepHeightView', () {
    testWidgets('should render height value from form', (
      WidgetTester tester,
    ) async {
      final FormGroup form = createForm(height: 1.5);

      await tester.pumpWidget(createWidget(form: form, submitAttempted: false));

      expect(find.text('1.50 m'), findsOneWidget);

      form.control('height').value = 2.0;
      await tester.pump();

      expect(find.text('2.00 m'), findsOneWidget);
    });

    testWidgets('should show validation error when invalid and submitted', (
      WidgetTester tester,
    ) async {
      final FormGroup form = createForm();

      await tester.pumpWidget(createWidget(form: form, submitAttempted: true));

      expect(
        find.text('Informe uma altura valida para continuar.'),
        findsOneWidget,
      );
    });
  });
}
