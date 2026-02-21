import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

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
      attachments: attachmentsRaw.whereType<Json>().map((Json attachment) {
        return AttachmentDto(
          kind: attachment['kind']?.toString() ?? '',
          key: attachment['key']?.toString() ?? '',
          name: attachment['name']?.toString() ?? '',
          size: (attachment['size'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
    );
  }

  static Json toJson(MessageDto dto) {
    return <String, dynamic>{
      'id': dto.id,
      'content': dto.content,
      'sender_id': dto.senderId,
      'receiver_id': dto.receiverId,
      'sent_at': dto.sentAt.toIso8601String(),
      'attachments': dto.attachments.map((AttachmentDto attachment) {
        return <String, dynamic>{
          'kind': attachment.kind,
          'key': attachment.key,
          'name': attachment.name,
          'size': attachment.size,
        };
      }).toList(),
    };
  }
}
