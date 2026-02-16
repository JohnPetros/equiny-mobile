import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart'
    as profiling_service;
import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/auth/mappers/owner_mapper.dart';
import 'package:equiny/rest/profiling/mappers/gallery_mapper.dart';
import 'package:equiny/rest/profiling/mappers/horse_mapper.dart';

class ProfilingService implements profiling_service.ProfilingService {
  final RestClient _restClient;

  ProfilingService(this._restClient);

  @override
  Future<RestResponse<OwnerDto>> fetchOwner() async {
    final RestResponse<Json> response = await _restClient.get(
      '/profiling/owners/me',
    );

    if (response.isFailure) {
      return RestResponse<OwnerDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(OwnerMapper.toDto);
  }

  @override
  Future<RestResponse<HorseDto>> createHorse({required HorseDto horse}) async {
    final RestResponse<Json> response = await _restClient.post(
      '/profiling/horses',
      body: HorseMapper.toPayload(horse),
    );

    if (response.isFailure) {
      return RestResponse<HorseDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(HorseMapper.toDto);
  }

  @override
  Future<RestResponse<GalleryDto>> createHorseGallery({
    required String horseId,
    required GalleryDto gallery,
  }) async {
    final RestResponse<Json> response = await _restClient.post(
      '/profiling/horses/$horseId/gallery',
      body: GalleryMapper.toPayload(gallery),
    );

    if (response.isFailure) {
      return RestResponse<GalleryDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(GalleryMapper.toDto);
  }
}
