import 'package:equiny/core/shared/interfaces/location_service.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();

    when(() => mockLocationService.fetchStates()).thenAnswer(
      (_) async => RestResponse<List<String>>(
        body: <String>['SP', 'RJ', 'MG'],
      ),
    );

    when(() => mockLocationService.fetchCities(any())).thenAnswer(
      (_) async => RestResponse<List<String>>(
        body: <String>['Sao Paulo', 'Campinas', 'Santos'],
      ),
    );
  });

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
    return ProviderScope(
      overrides: [
        onboardingStepLocationPresenterProvider.overrideWith(
          (ref) => OnboardingStepLocationPresenter(mockLocationService),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: OnboardingStepLocationView(
            form: form,
            submitAttempted: submitAttempted,
          ),
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
      await tester.pumpAndSettle();

      expect(find.text('Estado'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
    });

    testWidgets('should load states on init', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          submitAttempted: false,
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockLocationService.fetchStates()).called(1);
    });

    testWidgets('should display autocomplete suggestions for state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          submitAttempted: false,
        ),
      );
      await tester.pumpAndSettle();

      final stateFinder = find.widgetWithText(TextField, 'Estado');
      expect(stateFinder, findsOneWidget);
    });

    testWidgets('should display autocomplete suggestions for city', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          submitAttempted: false,
        ),
      );
      await tester.pumpAndSettle();

      final cityFinder = find.widgetWithText(TextField, 'Cidade');
      expect(cityFinder, findsOneWidget);
    });
  });
}

