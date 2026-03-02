import 'package:equiny/core/shared/interfaces/geolocation_driver.dart';
import 'package:equiny/drivers/geolocation-driver/geolocator/geolocator_geolocation_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geolocationDriverProvider = Provider<GeolocationDriver>((ref) {
  return GeolocatorGeolocationDriver();
});
