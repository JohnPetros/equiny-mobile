import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class HorseMapper {
  static Json toPayload(HorseDto horse) {
    return <String, dynamic>{
      'name': horse.name,
      'birth_month': horse.birthMonth,
      'birth_year': horse.birthYear,
      'breed': horse.breed,
      'sex': horse.sex,
      'height': horse.height,
      'location': <String, dynamic>{
        'city': horse.location.city,
        'state': horse.location.state,
      },
    };
  }

  static HorseDto toDto(Json body) {
    final Json location = _readMap(body['location']);
    return HorseDto(
      id: body['id']?.toString(),
      name: body['name']?.toString() ?? '',
      birthMonth: _readInt(body['birth_month']),
      birthYear: _readInt(body['birth_year']),
      breed: body['breed']?.toString() ?? '',
      sex: body['sex']?.toString() ?? '',
      height: _readDouble(body['height']),
      location: LocationDto(
        city: location['city']?.toString() ?? '',
        state: location['state']?.toString() ?? '',
      ),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static Json _readMap(dynamic value) {
    if (value is Json) {
      return value;
    }
    return <String, dynamic>{};
  }
}
