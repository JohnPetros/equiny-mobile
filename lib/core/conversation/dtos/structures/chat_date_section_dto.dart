import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';

class ChatDateSectionDto {
  final DateTime date;
  final String label;
  final List<MessageDto> messages;

  const ChatDateSectionDto({
    required this.date,
    required this.label,
    required this.messages,
  });
}
