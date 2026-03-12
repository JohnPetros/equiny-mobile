import 'package:equiny/core/profiling/dtos/structures/icebreaker_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class IcebreakerSuggestionMapper {
  static IcebreakerDto toDto(Json json) {
    final dynamic rawData = json['data'];
    final Json data = rawData is Map<String, dynamic> ? rawData : json;
    final String content = data['content']?.toString() ?? '';

    return IcebreakerDto(content: content);
  }
}
