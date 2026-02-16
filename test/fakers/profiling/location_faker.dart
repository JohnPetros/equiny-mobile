import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

class LocationFaker {
  static LocationDto fakeDto({String? city, String? state}) {
    return LocationDto(city: city ?? 'Sao Paulo', state: state ?? 'SP');
  }

  static List<LocationDto> fakeManyDto({int length = 2}) {
    return List<LocationDto>.generate(
      length,
      (int index) => fakeDto(city: 'City $index', state: 'ST'),
    );
  }
}
