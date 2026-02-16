import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_breed/onboarding_step_breed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  const List<String> breedOptions = <String>['Mangalarga', 'Quarto de Milha'];

  FormGroup createForm({String? breed}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'breed': FormControl<String>(
        value: breed,
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
        body: OnboardingStepBreedView(
          form: form,
          submitAttempted: submitAttempted,
          breedOptions: breedOptions,
        ),
      ),
    );
  }

  group('OnboardingStepBreedView', () {
    testWidgets('should render all breed options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: false),
      );

      for (final String breed in breedOptions) {
        expect(find.text(breed), findsOneWidget);
      }
    });

    testWidgets('should update form value when option is tapped', (
      WidgetTester tester,
    ) async {
      final FormGroup form = createForm();

      await tester.pumpWidget(createWidget(form: form, submitAttempted: false));

      await tester.tap(find.text('Mangalarga'));
      await tester.pump();

      expect(form.control('breed').value, 'Mangalarga');
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show error message when submitted and empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(form: createForm(), submitAttempted: true),
      );

      expect(find.text('Selecione uma raca para continuar.'), findsOneWidget);
    });
  });
}
