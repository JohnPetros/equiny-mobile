import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class MessageAttachmentMapper {
  static MessageAttachmentDto toDto(Json json) {
    return MessageAttachmentDto(
      kind: json['kind']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      size: (json['size'] as num?)?.toDouble() ?? 0,
    );
  }

  static Json toJson(MessageAttachmentDto dto) {
    return <String, dynamic>{
      'kind': dto.kind,
      'key': dto.key,
      'name': dto.name,
      'size': dto.size,
    };
  }
}
