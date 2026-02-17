import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm({String? phone, String? bio}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        value: 'Joao Silva',
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'email': FormControl<String>(
        value: 'joao@equiny.com',
        validators: <Validator<dynamic>>[Validators.required, Validators.email],
      ),
      'phone': FormControl<String>(value: phone),
      'bio': FormControl<String>(value: bio),
    });
  }

  Widget createWidget(FormGroup form) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ReactiveForm(
            formGroup: form,
            child: ProfileOwnerFormSectionView(form: form),
          ),
        ),
      ),
    );
  }

  group('ProfileOwnerFormSectionView', () {
    testWidgets('should render owner form sections and labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(createForm()));

      expect(find.text('DADOS PESSOAIS'), findsOneWidget);
      expect(find.text('CONTATO'), findsOneWidget);
      expect(find.text('SOBRE VOCE'), findsOneWidget);
      expect(find.text('Nome Completo'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Bio'), findsOneWidget);
    });

    testWidgets('should show phone error and bio counter', (
      WidgetTester tester,
    ) async {
      final form = createForm(phone: '123', bio: 'abc');

      await tester.pumpWidget(createWidget(form));
      await tester.pump();

      expect(
        find.text('Telefone invalido - insira 11 digitos'),
        findsOneWidget,
      );
      expect(find.text('3/300'), findsOneWidget);
    });
  });
}
