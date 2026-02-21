import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class HorseMatchMapper {
  static HorseMatchDto toDto(Json body) {
    final Json? ownerAvatarRaw = body['owner_avatar'] as Json?;
    final Json ownerLocation =
        body['owner_location'] as Json? ?? <String, dynamic>{};

    return HorseMatchDto(
      ownerId: body['owner_id']?.toString() ?? '',
      ownerName: body['owner_name']?.toString() ?? '',
      ownerAvatar: ownerAvatarRaw != null
          ? ImageDto(
              key: ownerAvatarRaw['key']?.toString() ?? '',
              name: ownerAvatarRaw['name']?.toString() ?? '',
            )
          : null,
      ownerHorseId: body['owner_horse_id']?.toString() ?? '',
      ownerLocation: LocationDto(
        city: ownerLocation['city']?.toString() ?? '',
        state: ownerLocation['state']?.toString() ?? '',
      ),
      isViewed: body['is_viewed'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(body['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<HorseMatchDto> toDtoList(Json body) {
    final List<dynamic> rawList =
        body['items'] as List<dynamic>? ??
        body['data']?['items'] as List<dynamic>? ??
        <dynamic>[];

    return rawList.whereType<Json>().map(HorseMatchMapper.toDto).toList();
  }
}
