import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class ImageMapper {
  static ImageDto toDto(Json body) {
    return ImageDto(
      key: body['key']?.toString() ?? '',
      name: body['name']?.toString() ?? '',
    );
  }

  static List<ImageDto> toDtoList(Json body) {
    final dynamic data = body['items'];
    final List<dynamic> imagesRaw;
    if (data is List<dynamic>) {
      imagesRaw = data;
    } else if (data is Map<String, dynamic>) {
      imagesRaw = (data['images'] as List<dynamic>?) ?? <dynamic>[];
    } else {
      imagesRaw = (body['images'] as List<dynamic>?) ?? <dynamic>[];
    }

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
