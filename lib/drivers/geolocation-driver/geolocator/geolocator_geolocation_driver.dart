import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/interfaces/geolocation_driver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorGeolocationDriver implements GeolocationDriver {
  static const Map<String, String> _ufToBrazilianState = <String, String>{
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  static const Map<String, String> _normalizedStateToAccented =
      <String, String>{
        'Acre': 'Acre',
        'Alagoas': 'Alagoas',
        'Amapa': 'Amapá',
        'Amazonas': 'Amazonas',
        'Bahia': 'Bahia',
        'Ceara': 'Ceará',
        'Distrito Federal': 'Distrito Federal',
        'Espirito Santo': 'Espírito Santo',
        'Goias': 'Goiás',
        'Maranhao': 'Maranhão',
        'Mato Grosso': 'Mato Grosso',
        'Mato Grosso do Sul': 'Mato Grosso do Sul',
        'Minas Gerais': 'Minas Gerais',
        'Para': 'Pará',
        'Paraiba': 'Paraíba',
        'Parana': 'Paraná',
        'Pernambuco': 'Pernambuco',
        'Piaui': 'Piauí',
        'Rio de Janeiro': 'Rio de Janeiro',
        'Rio Grande do Norte': 'Rio Grande do Norte',
        'Rio Grande do Sul': 'Rio Grande do Sul',
        'Rondonia': 'Rondônia',
        'Roraima': 'Roraima',
        'Santa Catarina': 'Santa Catarina',
        'Sao Paulo': 'São Paulo',
        'Sergipe': 'Sergipe',
        'Tocantins': 'Tocantins',
      };

  @override
  Future<LocationDto> detectCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const GeolocationFailure(GeolocationFailureReason.serviceDisabled);
    }

    final LocationPermission permission = await _resolvePermission();

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw const GeolocationFailure(GeolocationFailureReason.permissionDenied);
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } on Exception {
      throw const GeolocationFailure(
        GeolocationFailureReason.locationUnavailable,
      );
    }

    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } on Exception {
      throw const GeolocationFailure(
        GeolocationFailureReason.reverseGeocodingFailed,
      );
    }

    if (placemarks.isEmpty) {
      throw const GeolocationFailure(
        GeolocationFailureReason.reverseGeocodingFailed,
      );
    }

    final Placemark placemark = placemarks.first;
    final String city = _resolveCity(placemark);
    final String state = _resolveState(placemark);

    if (city.isEmpty || state.isEmpty) {
      throw const GeolocationFailure(
        GeolocationFailureReason.reverseGeocodingFailed,
      );
    }

    return LocationDto(
      city: city,
      state: state,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<LocationDto?> resolveCoordinates({
    required String city,
    required String state,
  }) async {
    final String normalizedCity = city.trim();
    final String normalizedState = state.trim();
    if (normalizedCity.isEmpty || normalizedState.isEmpty) {
      return null;
    }

    final List<Location> locations;
    try {
      locations = await locationFromAddress(
        '$normalizedCity, $normalizedState, Brasil',
      );
    } on Exception {
      return null;
    }

    if (locations.isEmpty) {
      return null;
    }

    final Location location = locations.first;
    return LocationDto(
      city: normalizedCity,
      state: normalizedState,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  String _resolveCity(Placemark placemark) {
    return (placemark.subAdministrativeArea ?? '').trim();
  }

  String _resolveState(Placemark placemark) {
    final String state = (placemark.administrativeArea ?? '').trim();
    if (state.isEmpty) {
      return '';
    }

    final String normalized = _normalizeStateName(state);
    if (normalized.length == 2) {
      return _ufToBrazilianState[normalized] ?? '';
    }

    return _normalizedStateToAccented[normalized] ?? '';
  }

  String _normalizeStateName(String state) {
    final String normalized = state
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .trim();

    if (normalized.length == 2) {
      return normalized.toUpperCase();
    }

    return normalized
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Future<LocationPermission> _resolvePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const GeolocationFailure(
        GeolocationFailureReason.permissionDeniedForever,
      );
    }

    if (permission == LocationPermission.denied) {
      throw const GeolocationFailure(GeolocationFailureReason.permissionDenied);
    }

    return permission;
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
