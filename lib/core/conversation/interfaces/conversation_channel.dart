import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/events/chat_participant_entered_event.dart';
import 'package:equiny/core/conversation/events/message_sent_event.dart';

abstract class ConversationChannel {
  Future<void> emitMessageSentEvent(MessageSentEvent event);

  Future<void> emitChatParticipantEnteredEvent(
    ChatParticipantEnteredEvent event,
  );

  void Function() onMessageReceived(Function(MessageDto message) callback);
}
