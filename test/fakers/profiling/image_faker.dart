import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class ImageFaker {
  static ImageDto fakeDto({String? key, String? name}) {
    return ImageDto(key: key ?? 'image-key', name: name ?? 'image-name.jpg');
  }

  static List<ImageDto> fakeManyDto({int length = 2}) {
    return List<ImageDto>.generate(
      length,
      (int index) =>
          fakeDto(key: 'image-key-$index', name: 'image-name-$index.jpg'),
    );
  }
}
