import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

class LocationFaker {
  static LocationDto fakeDto({
    String? city,
    String? state,
    double? latitude,
    double? longitude,
  }) {
    return LocationDto(
      city: city ?? 'Sao Paulo',
      state: state ?? 'SP',
      latitude: latitude ?? -23.5505,
      longitude: longitude ?? -46.6333,
    );
  }

  static List<LocationDto> fakeManyDto({int length = 2}) {
    return List<LocationDto>.generate(
      length,
      (int index) => fakeDto(
        city: 'City $index',
        state: 'ST',
        latitude: -23.0 - index,
        longitude: -46.0 - index,
      ),
    );
  }
}
