import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class ImageMapper {
  static List<ImageDto> toDtoList(Json body) {
    final List<dynamic> imagesRaw =
        (body['images'] as List<dynamic>?) ?? <dynamic>[];

    if (imagesRaw.isEmpty && body['key'] != null) {
      return <ImageDto>[
        ImageDto(
          key: body['key']?.toString() ?? '',
          name: body['name']?.toString() ?? '',
        ),
      ];
    }

    return imagesRaw.map((dynamic item) {
      final Json image = item is Json ? item : <String, dynamic>{};
      return ImageDto(
        key: image['key']?.toString() ?? '',
        name: image['name']?.toString() ?? '',
      );
    }).toList();
  }
}
