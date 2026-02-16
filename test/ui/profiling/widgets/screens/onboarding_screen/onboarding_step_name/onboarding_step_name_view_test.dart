import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_name/onboarding_step_name_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm({String? name}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        value: name,
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
    });
  }

  Widget createWidget(FormGroup form, {required bool submitAttempted}) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingStepNameView(
          form: form,
          submitAttempted: submitAttempted,
        ),
      ),
    );
  }

  group('OnboardingStepNameView', () {
    testWidgets('should render base content', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(createForm(name: 'Diamante'), submitAttempted: false),
      );

      expect(find.text('Qual e o nome do seu cavalo?'), findsOneWidget);
      expect(find.text('Nome do cavalo'), findsOneWidget);
      expect(find.text('Ex.: Diamante'), findsOneWidget);
    });

    testWidgets('should show validation message when invalid and submitted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(createForm(), submitAttempted: true),
      );

      expect(find.text('Campo obrigatorio.'), findsOneWidget);
    });
  });
}
