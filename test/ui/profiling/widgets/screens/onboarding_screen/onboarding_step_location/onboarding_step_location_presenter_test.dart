import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/interfaces/location_service.dart';
import 'package:equiny/core/shared/interfaces/geolocation_driver.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MockLocationService extends Mock implements LocationService {}

class MockGeolocationDriver extends Mock implements GeolocationDriver {}

void main() {
  late MockLocationService locationService;
  late MockGeolocationDriver geolocationDriver;
  late OnboardingStepLocationPresenter presenter;

  setUp(() {
    locationService = MockLocationService();
    geolocationDriver = MockGeolocationDriver();
    presenter = OnboardingStepLocationPresenter(
      locationService,
      geolocationDriver,
    );
  });

  tearDown(() {
    presenter.dispose();
  });

  group('OnboardingStepLocationPresenter', () {
    group('loadStates', () {
      test('should load states successfully', () async {
        final states = <String>['SP', 'RJ', 'MG', 'BA'];
        when(
          () => locationService.fetchStates(),
        ).thenAnswer((_) async => RestResponse<List<String>>(body: states));

        await presenter.loadStates();

        expect(presenter.states.value, states);
        expect(presenter.isLoadingStates.value, isFalse);
        expect(presenter.errorMessage.value, isNull);
      });

      test('should handle error when loading states', () async {
        const errorMsg = 'Erro ao buscar estados';
        when(() => locationService.fetchStates()).thenAnswer(
          (_) async => RestResponse<List<String>>(
            statusCode: 500,
            errorMessage: errorMsg,
          ),
        );

        await presenter.loadStates();

        expect(presenter.states.value, isEmpty);
        expect(presenter.isLoadingStates.value, isFalse);
        expect(presenter.errorMessage.value, errorMsg);
      });

      test('should set loading state while fetching', () async {
        when(() => locationService.fetchStates()).thenAnswer((_) async {
          expect(presenter.isLoadingStates.value, isTrue);
          return RestResponse<List<String>>(body: <String>[]);
        });

        await presenter.loadStates();

        expect(presenter.isLoadingStates.value, isFalse);
      });
    });

    group('loadCities', () {
      test('should load cities successfully', () async {
        const state = 'SP';
        final cities = <String>['Sao Paulo', 'Campinas', 'Santos'];
        when(
          () => locationService.fetchCities(state),
        ).thenAnswer((_) async => RestResponse<List<String>>(body: cities));

        await presenter.loadCities(state);

        expect(presenter.cities.value, cities);
        expect(presenter.isLoadingCities.value, isFalse);
        expect(presenter.errorMessage.value, isNull);
      });

      test('should handle error when loading cities', () async {
        const state = 'SP';
        const errorMsg = 'Erro ao buscar cidades';
        when(() => locationService.fetchCities(state)).thenAnswer(
          (_) async => RestResponse<List<String>>(
            statusCode: 500,
            errorMessage: errorMsg,
          ),
        );

        await presenter.loadCities(state);

        expect(presenter.cities.value, isEmpty);
        expect(presenter.isLoadingCities.value, isFalse);
        expect(presenter.errorMessage.value, errorMsg);
      });

      test('should clear cities when state is empty', () async {
        presenter.cities.value = <String>['Sao Paulo', 'Campinas'];

        await presenter.loadCities('');

        expect(presenter.cities.value, isEmpty);
        verifyNever(() => locationService.fetchCities(any()));
      });

      test('should set loading state while fetching', () async {
        const state = 'SP';
        when(() => locationService.fetchCities(state)).thenAnswer((_) async {
          expect(presenter.isLoadingCities.value, isTrue);
          return RestResponse<List<String>>(body: <String>[]);
        });

        await presenter.loadCities(state);

        expect(presenter.isLoadingCities.value, isFalse);
      });
    });

    group('filterStates', () {
      setUp(() {
        presenter.states.value = <String>['SP', 'RJ', 'MG', 'BA', 'RS'];
      });

      test('should return all states when query is empty', () {
        final result = presenter.filterStates('');

        expect(result, presenter.states.value);
      });

      test('should filter states by query', () {
        final result = presenter.filterStates('s');

        expect(result, <String>['SP', 'RS']);
      });

      test('should be case insensitive', () {
        final result = presenter.filterStates('sp');

        expect(result, <String>['SP']);
      });

      test('should trim query', () {
        final result = presenter.filterStates('  sp  ');

        expect(result, <String>['SP']);
      });
    });

    group('filterCities', () {
      setUp(() {
        presenter.cities.value = <String>[
          'Sao Paulo',
          'Campinas',
          'Santos',
          'Sorocaba',
        ];
      });

      test('should return all cities when query is empty', () {
        final result = presenter.filterCities('');

        expect(result, presenter.cities.value);
      });

      test('should filter cities by query', () {
        final result = presenter.filterCities('sa');

        expect(result, <String>['Sao Paulo', 'Santos']);
      });

      test('should be case insensitive', () {
        final result = presenter.filterCities('SAO');

        expect(result, <String>['Sao Paulo']);
      });

      test('should trim query', () {
        final result = presenter.filterCities('  campinas  ');

        expect(result, <String>['Campinas']);
      });
    });

    group('detectAndApplyCurrentLocation', () {
      test('should fill city, state and coordinates in form', () async {
        final form = FormGroup(<String, AbstractControl<Object?>>{
          'city': FormControl<String>(),
          'state': FormControl<String>(),
          'latitude': FormControl<double>(),
          'longitude': FormControl<double>(),
        });

        when(() => geolocationDriver.detectCurrentLocation()).thenAnswer(
          (_) async => const LocationDto(
            city: 'Sao Paulo',
            state: 'SP',
            latitude: -23.5505,
            longitude: -46.6333,
          ),
        );
        when(() => locationService.fetchCities('SP')).thenAnswer(
          (_) async => RestResponse<List<String>>(body: <String>['Sao Paulo']),
        );

        await presenter.detectAndApplyCurrentLocation(form);

        expect(form.control('state').value, 'SP');
        expect(form.control('city').value, 'Sao Paulo');
        expect(form.control('latitude').value, -23.5505);
        expect(form.control('longitude').value, -46.6333);
      });
    });
  });
}
