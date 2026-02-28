import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class ConversationService {
  Future<RestResponse<List<ChatDto>>> fetchChats();
  Future<RestResponse<ChatDto>> fetchChat({required String chatId});
  Future<RestResponse<PaginationResponse<MessageDto>>> fetchMessagesList({
    required String chatId,
    required int limit,
    required String? cursor,
  });
  Future<RestResponse<ChatDto>> createChat({
    required String recipientId,
    required String senderId,
    required String recipientHorseId,
    required String senderHorseId,
  });
  Future<RestResponse<MessageDto>> sendMessage({
    required String chatId,
    required String? content,
    required List<MessageAttachmentDto> attachments,
  });
}
