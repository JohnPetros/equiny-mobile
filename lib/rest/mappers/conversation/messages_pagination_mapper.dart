import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/conversation/message_mapper.dart';

class MessagesPaginationMapper {
  static PaginationResponse<MessageDto> toPagination(Json body) {
    final Json data = body['data'] as Json? ?? body;
    final List<MessageDto> items =
        (data['items'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Json>()
            .map(MessageMapper.toDto)
            .toList();

    return PaginationResponse<MessageDto>(
      items: items,
      nextCursor: data['next_cursor']?.toString() ?? '',
      limit: (data['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
