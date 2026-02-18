import 'package:equiny/core/matching/dtos/structures/swipe_dto.dart';
import 'package:equiny/core/matching/interfaces/matching_service.dart'
    as matching_service;
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/matching/swipe_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class MatchingService extends Service
    implements matching_service.MatchingService {
  MatchingService(super.restClient);

  @override
  Future<RestResponse<SwipeDto>> swipeHorse({
    required SwipeDto swipeDto,
  }) async {
    final RestResponse<Json> response = await super.restClient.post(
      '/matching/swipes',
      body: SwipeMapper.toJson(swipeDto),
    );

    if (response.isFailure) {
      return RestResponse<SwipeDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(SwipeMapper.toDto);
  }
}
