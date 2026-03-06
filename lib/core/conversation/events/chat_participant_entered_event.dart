import 'package:equiny/core/shared/abstracts/event.dart';
import 'package:equiny/core/shared/types/json.dart';

class _Payload {
  final String participantId;
  final String chatId;

  _Payload({required this.chatId, required this.participantId});
}

class ChatParticipantEnteredEvent extends Event<_Payload> {
  static const String name = 'conversation/chat.participant.entered';
  final String chatId;
  final String participantId;

  ChatParticipantEnteredEvent({
    required this.chatId,
    required this.participantId,
  }) : super(
         name: name,
         payload: _Payload(chatId: chatId, participantId: participantId),
       );

  Json toJson() {
    return <String, dynamic>{
      'name': name,
      'payload': <String, dynamic>{
        'chat_id': chatId,
        'participant_id': participantId,
      },
    };
  }
}
