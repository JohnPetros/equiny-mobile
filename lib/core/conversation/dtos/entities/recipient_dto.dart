import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class RecipientDto {
  final String? id;
  final String? name;
  final ImageDto? avatar;

  const RecipientDto({this.id, required this.name, this.avatar});
}
