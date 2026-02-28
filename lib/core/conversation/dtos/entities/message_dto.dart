import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';

class MessageDto {
  final String? id;
  final String content;
  final String senderId;
  final String receiverId;
  final bool isReadByRecipient;
  final DateTime sentAt;
  final List<MessageAttachmentDto> attachments;

  const MessageDto({
    this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.sentAt,
    required this.isReadByRecipient,
    required this.attachments,
  });
}
