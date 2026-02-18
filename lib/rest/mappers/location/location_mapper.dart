import 'package:equiny/core/shared/types/json.dart';

class LocationMapper {
  static List<String> toStateList(Json json) {
    final List<dynamic> items = json['items'] as List<dynamic>;
    return items
        .map((dynamic item) => (item as Json)['sigla'] as String)
        .toList();
  }

  static List<String> toCityList(Json json) {
    final List<dynamic> items = json['items'] as List<dynamic>;
    return items
        .map((dynamic item) => (item as Json)['nome'] as String)
        .toList();
  }
}
