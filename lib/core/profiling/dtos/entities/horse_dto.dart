import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

class HorseDto {
  final String? id;
  final String name;
  final int birthMonth;
  final int birthYear;
  final String breed;
  final String sex;
  final double height;
  final LocationDto location;
  final String description;
  final bool isActive;

  const HorseDto({
    this.id,
    required this.name,
    required this.birthMonth,
    required this.birthYear,
    required this.breed,
    required this.sex,
    required this.height,
    required this.location,
    this.description = '',
    this.isActive = false,
  });
}
