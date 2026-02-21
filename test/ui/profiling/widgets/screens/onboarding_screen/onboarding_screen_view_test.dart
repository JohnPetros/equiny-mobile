import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_view.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/rest/services/location_service.dart' as location_service;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

import '../../../../../fakers/profiling/image_faker.dart';

class MockOnboardingScreenPresenter extends Mock
    implements OnboardingScreenPresenter {}

class MockLocationService extends Mock
    implements location_service.LocationService {}

void main() {
  late MockOnboardingScreenPresenter presenter;
  late Signal<FormGroup> formSignal;
  late Signal<int> currentStepIndex;
  late Signal<bool> isSubmitting;
  late Signal<bool> isUploadingImages;
  late Signal<bool> submitAttempted;
  late Signal<String?> generalError;
  late Signal<List<ImageDto>> uploadedImages;
  late Signal<bool> isFirstStep;
  late Signal<bool> isLastStep;
  late Signal<bool> canAdvance;
  late Signal<bool> canFinish;
  late SharedPreferences sharedPreferences;
  late MockLocationService locationService;

  FormGroup buildForm() {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(),
      'birthMonth': FormControl<int>(),
      'birthYear': FormControl<int>(),
      'breed': FormControl<String>(),
      'sex': FormControl<String>(),
      'height': FormControl<double>(),
      'city': FormControl<String>(),
      'state': FormControl<String>(),
    });
  }

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        onboardingScreenPresenterProvider.overrideWithValue(presenter),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        locationServiceProvider.overrideWithValue(locationService),
      ],
      child: const MaterialApp(home: OnboardingScreenView()),
    );
  }

  setUpAll(() {
    registerFallbackValue(ImageFaker.fakeDto());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sharedPreferences = await SharedPreferences.getInstance();

    presenter = MockOnboardingScreenPresenter();
    locationService = MockLocationService();
    formSignal = signal(buildForm());
    currentStepIndex = signal(0);
    isSubmitting = signal(false);
    isUploadingImages = signal(false);
    submitAttempted = signal(false);
    generalError = signal(null);
    uploadedImages = signal(<ImageDto>[]);
    isFirstStep = signal(true);
    isLastStep = signal(false);
    canAdvance = signal(false);
    canFinish = signal(false);

    when(() => presenter.form).thenReturn(formSignal);
    when(() => presenter.currentStepIndex).thenReturn(currentStepIndex);
    when(() => presenter.isSubmitting).thenReturn(isSubmitting);
    when(() => presenter.isUploadingImages).thenReturn(isUploadingImages);
    when(() => presenter.submitAttempted).thenReturn(submitAttempted);
    when(() => presenter.generalError).thenReturn(generalError);
    when(() => presenter.uploadedImages).thenReturn(uploadedImages);
    when(() => presenter.isFirstStep).thenReturn(isFirstStep);
    when(() => presenter.isLastStep).thenReturn(isLastStep);
    when(() => presenter.canAdvance).thenReturn(canAdvance);
    when(() => presenter.canFinish).thenReturn(canFinish);
    when(() => presenter.breedOptions).thenReturn(const <String>['Mangalarga']);
    when(() => presenter.sexOptions).thenReturn(const <String>['Macho']);
    when(() => presenter.goPreviousStep()).thenReturn(null);
    when(() => presenter.goNextStep()).thenReturn(null);
    when(() => presenter.submitOnboarding()).thenAnswer((_) async {});
    when(() => presenter.pickAndUploadImages()).thenAnswer((_) async {});
    when(() => presenter.retryImageUpload()).thenAnswer((_) async {});
    when(() => presenter.removeImage(any())).thenReturn(null);

    when(
      () => locationService.fetchStates(),
    ).thenAnswer((_) async => RestResponse<List<String>>(body: <String>[]));
    when(
      () => locationService.fetchCities(any()),
    ).thenAnswer((_) async => RestResponse<List<String>>(body: <String>[]));
  });

  group('OnboardingScreenView', () {
    testWidgets('should render initial step content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Cadastre seu primeiro cavalo'), findsOneWidget);
      expect(find.text('Qual e o nome do seu cavalo?'), findsOneWidget);
      expect(find.text('Avancar'), findsOneWidget);
    });

    testWidgets('should render general error when present', (
      WidgetTester tester,
    ) async {
      generalError.value = 'Erro geral';

      await tester.pumpWidget(createWidget());

      expect(find.text('Erro geral'), findsOneWidget);
    });

    testWidgets('should call goNextStep when advance tapped', (
      WidgetTester tester,
    ) async {
      canAdvance.value = true;
      isFirstStep.value = false;

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Avancar'));
      await tester.pump();

      verify(() => presenter.goNextStep()).called(1);
    });

    testWidgets('should call goPreviousStep when back tapped', (
      WidgetTester tester,
    ) async {
      isFirstStep.value = false;

      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      verify(() => presenter.goPreviousStep()).called(1);
    });

    testWidgets('should call submitOnboarding when last step finishes', (
      WidgetTester tester,
    ) async {
      isLastStep.value = true;
      canFinish.value = true;

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Concluir cadastro'));
      await tester.pump();

      verify(() => presenter.submitOnboarding()).called(1);
    });

    testWidgets('should call pickAndUploadImages on add button tap', (
      WidgetTester tester,
    ) async {
      currentStepIndex.value = 6;

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Adicionar foto'));
      await tester.pump();

      verify(() => presenter.pickAndUploadImages()).called(1);
    });
  });
}
