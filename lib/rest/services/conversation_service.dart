import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart'
    as conversation_service;
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/conversation/chat_mapper.dart';
import 'package:equiny/rest/mappers/conversation/message_attachment_mapper.dart';
import 'package:equiny/rest/mappers/conversation/message_mapper.dart';
import 'package:equiny/rest/mappers/conversation/messages_pagination_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class ConversationService extends Service
    implements conversation_service.ConversationService {
  ConversationService(super.restClient, super._cacheDriver);

  @override
  Future<RestResponse<List<ChatDto>>> fetchChats() async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/conversation/chats/list',
    );

    if (response.isFailure) {
      return RestResponse<List<ChatDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(ChatMapper.toDtoList);
  }

  @override
  Future<RestResponse<ChatDto>> createChat({
    required String recipientId,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.post(
      '/conversation/chats/',
      body: <String, dynamic>{'recipient_id': recipientId},
    );

    if (response.isFailure) {
      return RestResponse<ChatDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(ChatMapper.toDto);
  }

  @override
  Future<RestResponse<ChatDto>> fetchChat({required String recipientId}) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.post(
      '/conversation/chats/',
      queryParams: <String, dynamic>{'recipient_id': recipientId},
    );

    if (response.isFailure) {
      return RestResponse<ChatDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(ChatMapper.toDto);
  }

  @override
  Future<RestResponse<PaginationResponse<MessageDto>>> fetchMessagesList({
    required String chatId,
    required int limit,
    required String? cursor,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/conversation/chats/$chatId/messages',
      queryParams: <String, dynamic>{
        'limit': limit,
        if ((cursor ?? '').isNotEmpty) 'cursor': cursor,
      },
    );

    if (response.isFailure) {
      return RestResponse<PaginationResponse<MessageDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(MessagesPaginationMapper.toPagination);
  }

  @override
  Future<RestResponse<MessageDto>> sendMessage({
    required String chatId,
    required String? content,
    required List<MessageAttachmentDto> attachments,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.post(
      '/conversation/chats/$chatId/messages/',
      body: <String, dynamic>{
        'content': (content ?? '').trim().isEmpty ? null : content,
        'attachments': attachments.map(MessageAttachmentMapper.toJson).toList(),
      },
    );

    if (response.isFailure) {
      return RestResponse<MessageDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(MessageMapper.toDto);
  }
}
