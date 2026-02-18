import 'package:equiny/core/shared/interfaces/location_service.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equiny/rest/services.dart';
import 'package:signals/signals.dart';

class OnboardingStepLocationPresenter {
  final LocationService _locationService;

  final Signal<List<String>> states = signal(<String>[]);
  final Signal<List<String>> cities = signal(<String>[]);
  final Signal<bool> isLoadingStates = signal(false);
  final Signal<bool> isLoadingCities = signal(false);
  final Signal<String?> errorMessage = signal(null);

  OnboardingStepLocationPresenter(this._locationService);

  Future<void> loadStates() async {
    isLoadingStates.value = true;
    errorMessage.value = null;

    final RestResponse<List<String>> response = await _locationService
        .fetchStates();

    if (response.isSuccessful) {
      states.value = response.body;
    } else {
      errorMessage.value = response.errorMessage;
    }

    isLoadingStates.value = false;
  }

  Future<void> loadCities(String state) async {
    if (state.isEmpty) {
      cities.value = <String>[];
      return;
    }

    isLoadingCities.value = true;
    errorMessage.value = null;

    final RestResponse<List<String>> response = await _locationService
        .fetchCities(state);

    if (response.isSuccessful) {
      cities.value = response.body;
    } else {
      errorMessage.value = response.errorMessage;
    }

    isLoadingCities.value = false;
  }

  List<String> filterStates(String query) {
    if (query.isEmpty) return states.value;

    final String normalizedQuery = query.toLowerCase().trim();
    return states.value
        .where((String state) => state.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  List<String> filterCities(String query) {
    if (query.isEmpty) return cities.value;

    final String normalizedQuery = query.toLowerCase().trim();
    return cities.value
        .where((String city) => city.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  void dispose() {
    states.dispose();
    cities.dispose();
    isLoadingStates.dispose();
    isLoadingCities.dispose();
    errorMessage.dispose();
  }
}

final onboardingStepLocationPresenterProvider =
    Provider.autoDispose<OnboardingStepLocationPresenter>((ref) {
      final presenter = OnboardingStepLocationPresenter(
        ref.watch(locationServiceProvider),
      );

      ref.onDispose(presenter.dispose);

      return presenter;
    });
