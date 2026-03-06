import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';

import 'message_faker.dart';
import 'recipient_faker.dart';

class ChatFaker {
  static ChatDto fakeDto({
    String? id,
    RecipientDto? recipient,
    MessageDto? lastMessage,
    int unreadCount = 0,
  }) {
    return ChatDto(
      id: id ?? 'chat-id',
      recipient: recipient ?? RecipientFaker.fakeDto(),
      lastMessage: lastMessage ?? MessageFaker.fakeDto(),
      unreadCount: unreadCount,
    );
  }

  static List<ChatDto> fakeManyDto({int length = 2}) {
    return List<ChatDto>.generate(
      length,
      (int index) => fakeDto(
        id: 'chat-id-$index',
        recipient: RecipientFaker.fakeDto(
          id: 'recipient-id-$index',
          name: 'Recipient $index',
        ),
        lastMessage: MessageFaker.fakeDto(
          id: 'message-id-$index',
          content: 'Mensagem $index',
          sentAt: DateTime(2026, 1, index + 1, 10, 30),
        ),
      ),
    );
  }
}
