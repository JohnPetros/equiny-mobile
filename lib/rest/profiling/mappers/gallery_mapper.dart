import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class GalleryMapper {
  static Json toPayload(GalleryDto gallery) {
    return <String, dynamic>{
      'horse_id': gallery.horseId,
      'images': gallery.images
          .map(
            (ImageDto image) => <String, dynamic>{
              'key': image.key,
              'name': image.name,
            },
          )
          .toList(),
    };
  }

  static GalleryDto toDto(Json body) {
    final List<dynamic> imagesRaw =
        (body['images'] as List<dynamic>?) ?? <dynamic>[];

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
