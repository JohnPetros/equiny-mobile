import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/profiling/image_mapper.dart';

class RecipientMapper {
  static RecipientDto toDto(Json json) {
    final Json? avatarRaw = json['avatar'] as Json?;

    return RecipientDto(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      avatar: avatarRaw == null ? null : ImageMapper.toDto(avatarRaw),
    );
  }
}
