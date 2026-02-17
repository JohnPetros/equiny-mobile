import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

import 'location_faker.dart';

class HorsesFaker {
  static HorseDto fakeDto({
    String? id,
    String? name,
    int? birthMonth,
    int? birthYear,
    String? breed,
    String? sex,
    double? height,
    LocationDto? location,
    String? description,
    bool? isActive,
  }) {
    return HorseDto(
      id: id,
      name: name ?? 'Diamante',
      birthMonth: birthMonth ?? 6,
      birthYear: birthYear ?? 2020,
      breed: breed ?? 'Mangalarga',
      sex: sex ?? 'Macho',
      height: height ?? 1.6,
      location: location ?? LocationFaker.fakeDto(),
      description: description ?? 'Descricao do cavalo',
      isActive: isActive ?? false,
    );
  }

  static List<HorseDto> fakeManyDto({int length = 10}) {
    return List.generate(length, (index) => fakeDto());
  }
}
