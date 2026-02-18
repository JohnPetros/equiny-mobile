import 'package:equiny/core/matching/dtos/structures/swipe_dto.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class MatchingService {
  Future<RestResponse<SwipeDto>> swipeHorse({required SwipeDto swipeDto});
}
