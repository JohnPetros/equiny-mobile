import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

class HorseFeedFiltersDto {
  final String sex;
  final List<String> breeds;
  final AgeRangeDto ageRange;
  final LocationDto location;
  final int limit;
  final String? cursor;

  const HorseFeedFiltersDto({
    required this.sex,
    required this.breeds,
    required this.ageRange,
    required this.location,
    required this.limit,
    this.cursor,
  });

  HorseFeedFiltersDto copyWith({
    String? sex,
    List<String>? breeds,
    AgeRangeDto? ageRange,
    LocationDto? location,
    int? limit,
    String? cursor,
  }) {
    return HorseFeedFiltersDto(
      sex: sex ?? this.sex,
      breeds: breeds ?? this.breeds,
      ageRange: ageRange ?? this.ageRange,
      location: location ?? this.location,
      limit: limit ?? this.limit,
      cursor: cursor ?? this.cursor,
    );
  }
}
