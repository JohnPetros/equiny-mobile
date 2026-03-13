import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';

class HorseFeedFiltersDto {
  final String sex;
  final List<String> breeds;
  final AgeRangeDto ageRange;
  final int maxDistanceInKm;
  final int limit;
  final String? cursor;

  const HorseFeedFiltersDto({
    required this.sex,
    required this.breeds,
    required this.ageRange,
    required this.maxDistanceInKm,
    required this.limit,
    this.cursor,
  });

  HorseFeedFiltersDto copyWith({
    String? sex,
    List<String>? breeds,
    AgeRangeDto? ageRange,
    int? maxDistanceInKm,
    int? limit,
    String? cursor,
  }) {
    return HorseFeedFiltersDto(
      sex: sex ?? this.sex,
      breeds: breeds ?? this.breeds,
      ageRange: ageRange ?? this.ageRange,
      maxDistanceInKm: maxDistanceInKm ?? this.maxDistanceInKm,
      limit: limit ?? this.limit,
      cursor: cursor ?? this.cursor,
    );
  }
}
