import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/conversation/message_mapper.dart';
import 'package:equiny/rest/mappers/conversation/recipient_mapper.dart';

class ChatMapper {
  static ChatDto toDto(Json json) {
    return ChatDto(
      id: json['id']?.toString(),
      recipient: RecipientMapper.toDto(
        json['recipient'] as Json? ?? <String, dynamic>{},
      ),
      lastMessage: MessageMapper.toDto(
        json['last_message'] as Json? ?? <String, dynamic>{},
      ),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  static List<ChatDto> toDtoList(Json json) {
    final List<dynamic> rawList =
        json['items'] as List<dynamic>? ??
        json['data']?['items'] as List<dynamic>? ??
        <dynamic>[];

    return rawList.whereType<Json>().map(ChatMapper.toDto).toList();
  }
}
