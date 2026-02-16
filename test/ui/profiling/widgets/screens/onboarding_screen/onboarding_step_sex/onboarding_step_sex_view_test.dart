import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_sex/onboarding_step_sex_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  const List<String> sexOptions = <String>['Macho', 'Femea'];

  FormGroup createForm({String? sex}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'sex': FormControl<String>(
        value: sex,
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
        body: OnboardingStepSexView(
          form: form,
          submitAttempted: submitAttempted,
          sexOptions: sexOptions,
        ),
      ),
    );
  }

  group('OnboardingStepSexView', () {
    testWidgets('should render all sex options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: false),
      );

      for (final String option in sexOptions) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('should update form value when option is tapped', (
      WidgetTester tester,
    ) async {
      final FormGroup form = createForm();

      await tester.pumpWidget(createWidget(form: form, submitAttempted: false));

      await tester.tap(find.text('Macho'));
      await tester.pump();

      expect(form.control('sex').value, 'Macho');
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show error message when submitted and empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: true),
      );

      expect(find.text('Selecione o sexo para continuar.'), findsOneWidget);
    });
  });
}
