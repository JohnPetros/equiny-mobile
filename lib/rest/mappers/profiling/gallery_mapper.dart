import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class GalleryMapper {
  static Json toJson(GalleryDto gallery) {
    return <String, dynamic>{
      'images': gallery.images
          .map(
            (ImageDto image) => <String, String>{
              'key': image.key,
              'name': image.name,
            },
          )
          .toList(),
    };
  }

  static GalleryDto toDto(Json body) {
    final dynamic imagesSource = body['images'];
    final List<dynamic> imagesRaw = imagesSource is List<dynamic>
        ? imagesSource
        : <dynamic>[];

    return GalleryDto(
      horseId:
          body['horse_id']?.toString() ?? body['horseId']?.toString() ?? '',
      images: imagesRaw.map((dynamic image) {
        final Json imageMap = image is Json ? image : <String, dynamic>{};
        return ImageDto(
          key: imageMap['key']?.toString() ?? '',
          name: imageMap['name']?.toString() ?? '',
        );
      }).toList(),
    );
  }
}
