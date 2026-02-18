import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

class FeedHorseDto {
  final HorseDto horse;
  final GalleryDto gallery;

  const FeedHorseDto({required this.horse, required this.gallery});

  String get id => horse.id ?? '';

  String get name => horse.name;

  String get sex => horse.sex;

  int get birthMonth => horse.birthMonth;

  int get birthYear => horse.birthYear;

  String get breed => horse.breed;

  double get height => horse.height;

  LocationDto get location => horse.location;

  String get description => horse.description;

  List<String> get imageUrls {
    return gallery.images
        .map((ImageDto image) => image.key)
        .where((String value) => value.trim().isNotEmpty)
        .toList();
  }
}
