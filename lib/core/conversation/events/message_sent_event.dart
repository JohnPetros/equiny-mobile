import 'package:equiny/core/shared/abstracts/event.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';

class _Payload {
  final String messageContent;
  final String chatId;
  final String senderId;
  final List<MessageAttachmentDto> attachments;

  _Payload({
    required this.messageContent,
    required this.chatId,
    required this.senderId,
    required this.attachments,
  });
}

class MessageSentEvent extends Event<_Payload> {
  static const String name = 'conversation/message.sent';
  final String messageContent;
  final String chatId;
  final String senderId;
  final List<MessageAttachmentDto> attachments;

  MessageSentEvent({
    required this.messageContent,
    required this.chatId,
    required this.senderId,
    required this.attachments,
  }) : super(
         name: name,
         payload: _Payload(
           messageContent: messageContent,
           chatId: chatId,
           senderId: senderId,
           attachments: attachments,
         ),
       );
}
