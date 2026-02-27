import 'package:equiny/core/conversation/events/message_sent_event.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart'
    as conversation_channel;
import 'package:equiny/core/conversation/events/message_received_event.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/conversation/message_mapper.dart';
import 'package:equiny/rest/mappers/conversation/message_attachment_mapper.dart';
import 'package:equiny/websocket/channels/channel.dart';

class ConversationChannel extends Channel
    implements conversation_channel.ConversationChannel {
  ConversationChannel(super.websocketClient);

  Json _resolveMessagePayload(Json payload) {
    final Json? nestedMessage = payload['message'] as Json?;
    if (nestedMessage != null) {
      return nestedMessage;
    }
    return payload;
  }

  @override
  void Function() listen({
    required void Function(MessageReceivedEvent event) onMessageReceived,
  }) {
    return super.websocketClient.onData((data) {
      final (String name, Json payload) = parseEvent(data);
      switch (name) {
        case MessageReceivedEvent.name:
          onMessageReceived(
            MessageReceivedEvent(
              message: MessageMapper.toDto(_resolveMessagePayload(payload)),
              chatId: payload['chat_id'],
            ),
          );
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> emitMessageSentEvent(MessageSentEvent event) async {
    await super.websocketClient.send(<String, dynamic>{
      'name': event.getName(),
      'payload': <String, dynamic>{
        'message_content': event.payload.messageContent,
        'chat_id': event.payload.chatId,
        'sender_id': event.payload.senderId,
        'attachments': event.payload.attachments
            .map(MessageAttachmentMapper.toJson)
            .toList(),
      },
    });
  }
}
