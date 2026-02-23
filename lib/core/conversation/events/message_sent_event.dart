import 'package:equiny/core/shared/abstracts/event.dart';

class _Payload {
  final String messageContent;
  final String chatId;
  final String senderId;

  _Payload({
    required this.messageContent,
    required this.chatId,
    required this.senderId,
  });
}

class MessageSentEvent extends Event<_Payload> {
  static const String name = 'conversation/message.sent';
  final String messageContent;
  final String chatId;
  final String senderId;

  MessageSentEvent({
    required this.messageContent,
    required this.chatId,
    required this.senderId,
  }) : super(
         name: name,
         payload: _Payload(
           messageContent: messageContent,
           chatId: chatId,
           senderId: senderId,
         ),
       );
}
