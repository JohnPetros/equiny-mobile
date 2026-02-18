import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/types/json.dart';

class HorseFeedMapper {
  static Json toJson(HorseFeedFiltersDto filters) {
    return <String, dynamic>{
      'sex': filters.sex,
      'breeds': filters.breeds,
      'min_age': filters.ageRange.min,
      'max_age': filters.ageRange.max,
      'city': filters.location.city,
      'state': filters.location.state,
      'limit': filters.limit,
      if ((filters.cursor ?? '').isNotEmpty) 'cursor': filters.cursor,
    };
  }

  static PaginationResponse<FeedHorseDto> toFeedPagination(Json body) {
    final Json data = body['data'] as Json? ?? body;
    final List<FeedHorseDto> items =
        (data['items'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Json>()
            .map(toFeedHorseDto)
            .toList();
    final String nextCursor = data['next_cursor']?.toString() ?? '';
    final int limit = (data['limit'] as num?)?.toInt() ?? 0;

    return PaginationResponse<FeedHorseDto>(
      items: items,
      nextCursor: nextCursor,
      limit: limit,
    );
  }

  static FeedHorseDto toFeedHorseDto(Json body) {
    final Json horse = body['horse'] as Json? ?? <String, dynamic>{};
    final Json gallery = body['gallery'] as Json? ?? <String, dynamic>{};
    final Json location = horse['location'] as Json? ?? <String, dynamic>{};

    final List<ImageDto> images =
        (gallery['images'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Json>()
            .map(
              (Json image) => ImageDto(
                key: image['key']?.toString() ?? '',
                name: image['name']?.toString() ?? '',
              ),
            )
            .where((ImageDto image) => image.key.isNotEmpty)
            .toList();

    final String horseId = horse['id']?.toString() ?? '';

    return FeedHorseDto(
      horse: HorseDto(
        id: horseId.isEmpty ? null : horseId,
        name: horse['name']?.toString() ?? '',
        birthMonth: (horse['birth_month'] as num?)?.toInt() ?? 0,
        birthYear: (horse['birth_year'] as num?)?.toInt() ?? 0,
        breed: horse['breed']?.toString() ?? '',
        sex: horse['sex']?.toString() ?? '',
        height: (horse['height'] as num?)?.toDouble() ?? 0,
        location: LocationDto(
          city: location['city']?.toString() ?? '',
          state: location['state']?.toString() ?? '',
        ),
        description: horse['description']?.toString() ?? '',
        isActive: horse['is_active'] as bool? ?? false,
      ),
      gallery: GalleryDto(horseId: horseId, images: images),
    );
  }
}
