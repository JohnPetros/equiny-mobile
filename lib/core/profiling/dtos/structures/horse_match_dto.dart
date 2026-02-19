import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class HorseMatchDto {
  final String ownerId;
  final String ownerName;
  final String ownerHorseId;
  final ImageDto? ownerAvatar;
  final LocationDto ownerLocation;
  final bool isViewed;
  final DateTime createdAt;

  const HorseMatchDto({
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerHorseId,
    required this.ownerLocation,
    required this.isViewed,
    required this.createdAt,
  });
}
