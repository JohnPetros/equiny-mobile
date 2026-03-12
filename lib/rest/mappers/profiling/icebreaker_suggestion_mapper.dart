import 'package:equiny/core/profiling/dtos/structures/icebreaker_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class IcebreakerSuggestionMapper {
  static IcebreakerDto toDto(Json json) {
    final Json data = json['data'] as Json? ?? json;
    final String content = data['content']?.toString() ?? '';

    return IcebreakerDto(content: content);
  }
}
