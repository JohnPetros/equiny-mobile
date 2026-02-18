import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';

abstract class ProfilingService {
  Future<RestResponse<OwnerDto>> fetchOwner();
  Future<RestResponse<PaginationResponse<FeedHorseDto>>> fetchHorseFeed({
    required String horseId,
    required String sex,
    required List<String> breeds,
    required AgeRangeDto ageRange,
    required LocationDto location,
    required int limit,
    required String? cursor,
  });
  Future<RestResponse<OwnerDto>> updateOwner({required OwnerDto owner});
  Future<RestResponse<List<HorseDto>>> fetchOwnerHorses();
  Future<RestResponse<HorseDto>> createHorse({required HorseDto horse});
  Future<RestResponse<GalleryDto>> createHorseGallery({
    required String horseId,
    required GalleryDto gallery,
  });
  Future<RestResponse<HorseDto>> updateHorse({required HorseDto horse});
  Future<RestResponse<GalleryDto>> fetchHorseGallery({required String horseId});
  Future<RestResponse<GalleryDto>> updateHorseGallery({
    required String horseId,
    required GalleryDto gallery,
  });
}
