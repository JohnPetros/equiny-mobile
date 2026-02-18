import 'package:equiny/core/matching/dtos/structures/swipe_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class SwipeMapper {
  static Json toJson(SwipeDto swipeDto) {
    return <String, dynamic>{
      'to_horse_id': swipeDto.toHorseId,
      'from_horse_id': swipeDto.fromHorseId,
      'decision': swipeDto.decision,
    };
  }

  static SwipeDto toDto(Json body) {
    return SwipeDto(
      toHorseId: _firstNonNull(body, <String>['to_horse_id', 'toHorseId'])
              ?.toString() ??
          '',
      fromHorseId:
          _firstNonNull(body, <String>['from_horse_id', 'fromHorseId'])
                  ?.toString() ??
              '',
      decision: _firstNonNull(body, <String>['decision'])?.toString() ?? '',
    );
  }

  static dynamic _firstNonNull(Json source, List<String> keys) {
    for (final String key in keys) {
      if (source.containsKey(key) && source[key] != null) {
        return source[key];
      }
    }
    return null;
  }
}
