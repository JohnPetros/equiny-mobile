import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class ConversationService {
  Future<RestResponse<List<ChatDto>>> fetchChats();
  Future<RestResponse<ChatDto>> fetchChat({required String chatId});
  Future<RestResponse<MessageDto>> sendMessage({required MessageDto message});
}
