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
      'description': horse.description,
      'is_active': horse.isActive,
      'location': <String, dynamic>{
        'city': horse.location.city,
        'state': horse.location.state,
      },
    };
  }

  static HorseDto toDto(Json body) {
    final Json location = _readMap(_firstNonNull(body, <String>['location']));
    return HorseDto(
      id: body['id']?.toString(),
      name: _firstNonNull(body, <String>['name'])?.toString() ?? '',
      birthMonth: _readInt(
        _firstNonNull(body, <String>['birth_month', 'birthMonth']),
      ),
      birthYear: _readInt(
        _firstNonNull(body, <String>['birth_year', 'birthYear']),
      ),
      breed: _firstNonNull(body, <String>['breed'])?.toString() ?? '',
      sex: _firstNonNull(body, <String>['sex'])?.toString() ?? '',
      height: _readDouble(_firstNonNull(body, <String>['height'])),
      location: LocationDto(
        city: _firstNonNull(location, <String>['city'])?.toString() ?? '',
        state: _firstNonNull(location, <String>['state'])?.toString() ?? '',
      ),
      description:
          _firstNonNull(body, <String>['description'])?.toString() ?? '',
      isActive: _readBool(
        _firstNonNull(body, <String>['is_active', 'isActive']),
      ),
    );
  }

  static dynamic _firstNonNull(Json source, List<String> keys) {
    for (final String key in keys) {
      if (source.containsKey(key) && source[key] != null) {
        return source[key];
      }
    }
    return null;
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

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}
