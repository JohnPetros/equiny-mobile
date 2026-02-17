import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm() {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(value: 'Joao Silva'),
      'email': FormControl<String>(value: 'joao@equiny.com'),
      'phone': FormControl<String>(value: '11999999999'),
      'bio': FormControl<String>(value: 'Criador de cavalos'),
    });
  }

  Widget createWidget({
    required bool isLoading,
    String? generalError,
    FormGroup? form,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileOwnerTabView(
          form: form ?? createForm(),
          isLoading: isLoading,
          generalError: generalError,
        ),
      ),
    );
  }

  group('ProfileOwnerTabView', () {
    testWidgets('should render loading indicator when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('should render owner sections and no error by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isLoading: false));

      expect(find.text('DADOS PESSOAIS'), findsOneWidget);
      expect(find.text('CONTATO'), findsOneWidget);
      expect(find.text('SOBRE VOCE'), findsOneWidget);
      expect(find.text('Perfil Verificado'), findsOneWidget);
      expect(find.text('Falha ao sincronizar'), findsNothing);
    });

    testWidgets('should render error message when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(isLoading: false, generalError: 'Falha ao sincronizar'),
      );

      expect(find.text('Falha ao sincronizar'), findsOneWidget);
    });
  });
}
