import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';

class ChatDto {
  final String? id;
  final RecipientDto recipient;
  final MessageDto lastMessage;
  final int unreadCount;

  const ChatDto({
    this.id,
    required this.recipient,
    required this.lastMessage,
    this.unreadCount = 0,
  });
}
