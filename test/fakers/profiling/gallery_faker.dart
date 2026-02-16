import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

import 'image_faker.dart';

class GalleryFaker {
  static GalleryDto fakeDto({String? horseId, List<ImageDto>? images}) {
    return GalleryDto(
      horseId: horseId ?? 'horse-id',
      images: images ?? ImageFaker.fakeManyDto(),
    );
  }

  static List<GalleryDto> fakeManyDto({int length = 2}) {
    return List<GalleryDto>.generate(
      length,
      (int index) => fakeDto(horseId: 'horse-$index'),
    );
  }
}
