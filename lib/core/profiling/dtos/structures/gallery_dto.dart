import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class GalleryDto {
  final String horseId;
  final List<ImageDto> images;

  const GalleryDto({required this.horseId, required this.images});
}
