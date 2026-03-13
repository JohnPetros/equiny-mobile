import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

enum GeolocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  locationUnavailable,
  reverseGeocodingFailed,
  unknown,
}

class GeolocationFailure implements Exception {
  final GeolocationFailureReason reason;

  const GeolocationFailure(this.reason);
}

abstract class GeolocationDriver {
  Future<LocationDto> detectCurrentLocation();
  Future<LocationDto?> resolveCoordinates({
    required String city,
    required String state,
  });
  Future<void> openAppSettings();
  Future<void> openLocationSettings();
}
