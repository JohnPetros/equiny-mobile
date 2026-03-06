import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/interfaces/geolocation_driver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorGeolocationDriver implements GeolocationDriver {
  static const Map<String, String> _brazilianStateToUf = <String, String>{
    'Acre': 'AC',
    'Alagoas': 'AL',
    'Amapa': 'AP',
    'Amazonas': 'AM',
    'Bahia': 'BA',
    'Ceara': 'CE',
    'Distrito Federal': 'DF',
    'Espirito Santo': 'ES',
    'Goias': 'GO',
    'Maranhao': 'MA',
    'Mato Grosso': 'MT',
    'Mato Grosso do Sul': 'MS',
    'Minas Gerais': 'MG',
    'Para': 'PA',
    'Paraiba': 'PB',
    'Parana': 'PR',
    'Pernambuco': 'PE',
    'Piaui': 'PI',
    'Rio de Janeiro': 'RJ',
    'Rio Grande do Norte': 'RN',
    'Rio Grande do Sul': 'RS',
    'Rondonia': 'RO',
    'Roraima': 'RR',
    'Santa Catarina': 'SC',
    'Sao Paulo': 'SP',
    'Sergipe': 'SE',
    'Tocantins': 'TO',
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

    return LocationDto(city: city, state: state);
  }

  String _resolveCity(Placemark placemark) {
    return (placemark.locality ?? placemark.subAdministrativeArea ?? '').trim();
  }

  String _resolveState(Placemark placemark) {
    final String state = (placemark.administrativeArea ?? '').trim();
    if (state.isEmpty) {
      return '';
    }

    final String normalized = _normalizeStateName(state);
    if (normalized.length == 2) {
      return normalized;
    }

    return _brazilianStateToUf[normalized] ?? '';
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
