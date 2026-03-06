import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/interfaces/geolocation_driver.dart';
import 'package:equiny/core/shared/interfaces/location_service.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/drivers/geolocation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class OnboardingStepLocationPresenter {
  final LocationService _locationService;
  final GeolocationDriver _geolocationDriver;

  final Signal<List<String>> states = signal(<String>[]);
  final Signal<List<String>> cities = signal(<String>[]);
  final Signal<bool> isLoadingStates = signal(false);
  final Signal<bool> isLoadingCities = signal(false);
  final Signal<String?> errorMessage = signal(null);

  final Signal<bool> isDetectingLocation = signal(false);
  final Signal<String?> geolocationMessage = signal(null);
  final Signal<bool> canOpenSettings = signal(false);
  final Signal<bool> shouldOpenAppSettings = signal(false);

  OnboardingStepLocationPresenter(
    this._locationService,
    this._geolocationDriver,
  );

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

  Future<void> detectAndApplyCurrentLocation(FormGroup form) async {
    if (isDetectingLocation.value) {
      return;
    }

    isDetectingLocation.value = true;
    geolocationMessage.value = null;
    canOpenSettings.value = false;
    shouldOpenAppSettings.value = false;

    try {
      final LocationDto location = await _geolocationDriver
          .detectCurrentLocation();

      form.control('state').value = location.state;
      await loadCities(location.state);
      form.control('city').value = location.city;

      geolocationMessage.value =
          'Localizacao detectada. Confira e ajuste se necessario.';
    } on GeolocationFailure catch (error) {
      _handleGeolocationFailure(error.reason);
    } catch (_) {
      geolocationMessage.value =
          'Nao foi possivel detectar sua localizacao agora. Preencha manualmente.';
      canOpenSettings.value = false;
      shouldOpenAppSettings.value = false;
    } finally {
      isDetectingLocation.value = false;
    }
  }

  Future<void> openRelevantSettings() async {
    if (!canOpenSettings.value) {
      return;
    }

    if (shouldOpenAppSettings.value) {
      await _geolocationDriver.openAppSettings();
      return;
    }

    await _geolocationDriver.openLocationSettings();
  }

  void _handleGeolocationFailure(GeolocationFailureReason reason) {
    switch (reason) {
      case GeolocationFailureReason.serviceDisabled:
        geolocationMessage.value =
            'Ative o servico de localizacao para usar o preenchimento automatico.';
        canOpenSettings.value = true;
        shouldOpenAppSettings.value = false;
        break;
      case GeolocationFailureReason.permissionDenied:
        geolocationMessage.value =
            'Permissao de localizacao negada. Voce pode tentar novamente.';
        canOpenSettings.value = false;
        shouldOpenAppSettings.value = false;
        break;
      case GeolocationFailureReason.permissionDeniedForever:
        geolocationMessage.value =
            'Permissao de localizacao bloqueada. Abra as configuracoes do app para liberar o acesso.';
        canOpenSettings.value = true;
        shouldOpenAppSettings.value = true;
        break;
      case GeolocationFailureReason.locationUnavailable:
        geolocationMessage.value =
            'Nao foi possivel obter sua posicao atual. Tente novamente em instantes.';
        canOpenSettings.value = false;
        shouldOpenAppSettings.value = false;
        break;
      case GeolocationFailureReason.reverseGeocodingFailed:
        geolocationMessage.value =
            'Localizacao obtida, mas nao foi possivel identificar cidade e estado automaticamente.';
        canOpenSettings.value = false;
        shouldOpenAppSettings.value = false;
        break;
      case GeolocationFailureReason.unknown:
        geolocationMessage.value =
            'Nao foi possivel detectar sua localizacao agora. Preencha manualmente.';
        canOpenSettings.value = false;
        shouldOpenAppSettings.value = false;
        break;
    }
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
    isDetectingLocation.dispose();
    geolocationMessage.dispose();
    canOpenSettings.dispose();
    shouldOpenAppSettings.dispose();
  }
}

final onboardingStepLocationPresenterProvider =
    Provider.autoDispose<OnboardingStepLocationPresenter>((ref) {
      final presenter = OnboardingStepLocationPresenter(
        ref.watch(locationServiceProvider),
        ref.watch(geolocationDriverProvider),
      );

      ref.onDispose(presenter.dispose);

      return presenter;
    });
