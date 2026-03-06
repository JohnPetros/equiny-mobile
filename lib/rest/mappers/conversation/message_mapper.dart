import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/conversation/message_attachment_mapper.dart';

class MessageMapper {
  static MessageDto toDto(Json json) {
    final List<dynamic> attachmentsRaw =
        json['attachments'] as List<dynamic>? ?? <dynamic>[];

    return MessageDto(
      id: json['id']?.toString(),
      content: json['content']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      sentAt:
          DateTime.tryParse(json['sent_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isReadByRecipient: json['is_read_by_recipient'] as bool? ?? false,
      attachments: attachmentsRaw
          .whereType<Json>()
          .map(MessageAttachmentMapper.toDto)
          .toList(),
    );
  }

  static Json toJson(MessageDto dto) {
    return <String, dynamic>{
      'id': dto.id,
      'content': dto.content,
      'sender_id': dto.senderId,
      'receiver_id': dto.receiverId,
      'sent_at': dto.sentAt.toIso8601String(),
      'is_read_by_recipient': dto.isReadByRecipient,
      'attachments': dto.attachments
          .map(MessageAttachmentMapper.toJson)
          .toList(),
    };
  }
}
