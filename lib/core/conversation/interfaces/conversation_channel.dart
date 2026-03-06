import 'package:equiny/core/conversation/events/message_received_event.dart';
import 'package:equiny/core/conversation/events/message_sent_event.dart';

abstract class ConversationChannel {
  Future<void> emitMessageSentEvent(MessageSentEvent event);

  void Function() listen({
    required void Function(MessageReceivedEvent event) onMessageReceived,
  });
}
