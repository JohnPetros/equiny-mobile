import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class HorseMapper {
  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Json toJson(HorseDto horse) {
    return <String, dynamic>{
      'name': horse.name,
      'birth_month': horse.birthMonth,
      'birth_year': horse.birthYear,
      'breed': horse.breed,
      'sex': horse.sex,
      'height': horse.height,
      'description': horse.description,
      'is_active': horse.isActive,
      'latitude': horse.location.latitude,
      'longitude': horse.location.longitude,
      'location': <String, dynamic>{
        'city': horse.location.city,
        'state': horse.location.state,
        'latitude': horse.location.latitude,
        'longitude': horse.location.longitude,
      },
    };
  }

  static HorseDto toDto(Json body) {
    final Json location = body['location'] as Json? ?? <String, dynamic>{};
    return HorseDto(
      id: body['id']?.toString(),
      name: body['name']?.toString() ?? '',
      birthMonth: (body['birth_month'] as num?)?.toInt() ?? 0,
      birthYear: (body['birth_year'] as num?)?.toInt() ?? 0,
      breed: body['breed']?.toString() ?? '',
      sex: body['sex']?.toString() ?? '',
      height: (body['height'] as num?)?.toDouble() ?? 0,
      location: LocationDto(
        city: location['city']?.toString() ?? '',
        state: location['state']?.toString() ?? '',
        latitude: _toDouble(location['latitude']),
        longitude: _toDouble(location['longitude']),
      ),
      description: body['description']?.toString() ?? '',
      isActive: body['is_active'] as bool? ?? false,
    );
  }
}
