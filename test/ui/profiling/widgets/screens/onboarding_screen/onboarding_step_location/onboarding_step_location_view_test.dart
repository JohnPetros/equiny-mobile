import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm({String? city, String? state}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'city': FormControl<String>(
        value: city,
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'state': FormControl<String>(
        value: state,
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
        body: OnboardingStepLocationView(
          form: form,
          submitAttempted: submitAttempted,
        ),
      ),
    );
  }

  group('OnboardingStepLocationView', () {
    testWidgets('should render city and state fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(city: 'Sao Paulo', state: 'SP'),
          submitAttempted: false,
        ),
      );

      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);
    });

    testWidgets('should show validation message when submitted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: true),
      );

      expect(find.text('Campo obrigatorio.'), findsWidgets);
    });
  });
}
