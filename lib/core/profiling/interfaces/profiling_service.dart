import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class ProfilingService {
  Future<RestResponse<OwnerDto>> fetchOwner();
  Future<RestResponse<HorseDto>> createHorse({required HorseDto horse});
  Future<RestResponse<GalleryDto>> createHorseGallery({
    required String horseId,
    required GalleryDto gallery,
  });
}
