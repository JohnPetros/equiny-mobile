import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

import 'image_faker.dart';
import 'location_faker.dart';

class HorseMatchFaker {
  static HorseMatchDto fakeDto({
    String? ownerId,
    String? ownerName,
    ImageDto? ownerAvatar,
    LocationDto? ownerLocation,
    String? ownerHorseId,
    String? ownerHorseName,
    ImageDto? ownerHorseImage,
    bool isViewed = false,
    DateTime? createdAt,
  }) {
    return HorseMatchDto(
      ownerId: ownerId ?? 'owner-id',
      ownerName: ownerName ?? 'Joao',
      ownerAvatar: ownerAvatar ?? ImageFaker.fakeDto(key: 'owner-avatar-key'),
      ownerLocation: ownerLocation ?? LocationFaker.fakeDto(),
      ownerHorseId: ownerHorseId ?? 'horse-id',
      ownerHorseName: ownerHorseName ?? 'Estrela',
      ownerHorseImage:
          ownerHorseImage ?? ImageFaker.fakeDto(key: 'horse-image-key'),
      isViewed: isViewed,
      createdAt: createdAt ?? DateTime(2026, 1, 2, 10, 30),
    );
  }

  static List<HorseMatchDto> fakeManyDto({int length = 2}) {
    return List<HorseMatchDto>.generate(
      length,
      (int index) => fakeDto(
        ownerId: 'owner-id-$index',
        ownerHorseId: 'horse-id-$index',
        ownerHorseName: 'Horse $index',
        createdAt: DateTime(2026, 1, index + 1, 10, 30),
      ),
    );
  }
}
