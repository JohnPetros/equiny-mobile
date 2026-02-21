import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';

class MessageFaker {
  static MessageDto fakeDto({
    String? id,
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? sentAt,
    List<AttachmentDto>? attachments,
  }) {
    return MessageDto(
      id: id ?? 'message-id',
      content: content ?? 'Mensagem',
      senderId: senderId ?? 'sender-id',
      receiverId: receiverId ?? 'receiver-id',
      sentAt: sentAt ?? DateTime(2026, 1, 1, 10, 30),
      attachments: attachments ?? const <AttachmentDto>[],
    );
  }
}
