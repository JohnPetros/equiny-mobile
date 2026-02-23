import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/shared/abstracts/event.dart';

class _Payload {
  final MessageDto message;
  final String chatId;

  _Payload({required this.message, required this.chatId});
}

class MessageReceivedEvent extends Event<_Payload> {
  static const String name = 'conversation/message.received';

  MessageReceivedEvent({required MessageDto message, required String chatId})
    : super(
        name: name,
        payload: _Payload(message: message, chatId: chatId),
      );
}
