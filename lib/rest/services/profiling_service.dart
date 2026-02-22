import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/gallery_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart'
    as profiling_service;
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/auth/owner_mapper.dart';
import 'package:equiny/rest/mappers/profiling/horse_feed_mapper.dart';
import 'package:equiny/rest/services/service.dart';
import 'package:equiny/rest/mappers/profiling/gallery_mapper.dart';
import 'package:equiny/rest/mappers/profiling/horse_mapper.dart';
import 'package:equiny/rest/mappers/profiling/horse_match_mapper.dart';

class ProfilingService extends Service
    implements profiling_service.ProfilingService {
  ProfilingService(super.restClient, super._cacheDriver);

  @override
  Future<RestResponse<OwnerDto>> fetchOwner() async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
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
  Future<RestResponse<OwnerPresenceDto>> fetchOwnerPresence({
    required String ownerId,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/owners/$ownerId/presence',
    );

    if (response.isFailure) {
      return RestResponse<OwnerPresenceDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody((Json body) {
      final Json data = body['data'] as Json? ?? body;
      return OwnerPresenceDto(
        ownerId: data['owner_id']?.toString() ?? ownerId,
        isOnline: data['is_online'] as bool? ?? false,
      );
    });
  }

  @override
  Future<RestResponse<OwnerDto>> updateOwner({required OwnerDto owner}) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.put(
      '/profiling/owners/me',
      body: OwnerMapper.toJson(owner),
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
  Future<RestResponse<List<HorseDto>>> fetchOwnerHorses() async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/owners/me/horses',
    );

    if (response.isFailure) {
      return RestResponse<List<HorseDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody((dynamic body) {
      final List<dynamic> list = body['items'];
      return list
          .map((dynamic horseRaw) => HorseMapper.toDto(horseRaw as Json))
          .toList();
    });
  }

  @override
  Future<RestResponse<PaginationResponse<FeedHorseDto>>> fetchHorseFeed({
    required String horseId,
    required String sex,
    required List<String> breeds,
    required AgeRangeDto ageRange,
    required LocationDto location,
    required int limit,
    required String? cursor,
  }) async {
    super.setAuthHeader();
    final queryParams = <String, dynamic>{
      'sex': sex,
      'breeds': breeds,
      'min_age': ageRange.min,
      'max_age': ageRange.max,
      'city': location.city,
      'state': location.state,
      'limit': limit,
      if ((cursor ?? '').isNotEmpty) 'cursor': cursor,
    };

    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/horses/$horseId/feed',
      queryParams: queryParams,
    );

    if (response.isFailure) {
      return RestResponse<PaginationResponse<FeedHorseDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(HorseFeedMapper.toFeedPagination);
  }

  @override
  Future<RestResponse<List<HorseMatchDto>>> fetchHorseMatches({
    required String horseId,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/horses/$horseId/matches',
    );

    if (response.isFailure) {
      return RestResponse<List<HorseMatchDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(HorseMatchMapper.toDtoList);
  }

  @override
  Future<RestResponse<void>> viewHorseMatch({
    required String fromHorseId,
    required String toHorseId,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.patch(
      '/profiling/horses/$fromHorseId/matches/$toHorseId',
    );

    if (response.isFailure) {
      return RestResponse<void>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return RestResponse<void>(statusCode: response.statusCode, body: null);
  }

  @override
  Future<RestResponse<List<String>>> fetchBreeds() async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/breeds',
    );

    if (response.isFailure) {
      return RestResponse<List<String>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody((Json body) {
      final List<dynamic> list = body['items'];
      return list.map((dynamic breed) => breed as String).toList();
    });
  }

  @override
  Future<RestResponse<HorseDto>> createHorse({required HorseDto horse}) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.post(
      '/profiling/horses',
      body: HorseMapper.toJson(horse),
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
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.post(
      '/profiling/horses/$horseId/gallery',
      body: GalleryMapper.toJson(gallery),
    );

    if (response.isFailure) {
      return RestResponse<GalleryDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(GalleryMapper.toDto);
  }

  @override
  Future<RestResponse<HorseDto>> updateHorse({required HorseDto horse}) async {
    super.setAuthHeader();
    final String horseId = horse.id ?? '';
    if (horseId.isEmpty) {
      return RestResponse<HorseDto>(
        statusCode: 400,
        errorMessage: 'Nao foi possivel atualizar o cavalo sem id.',
      );
    }

    final RestResponse<Json> response = await super.restClient.put(
      '/profiling/horses/$horseId',
      body: HorseMapper.toJson(horse),
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
  Future<RestResponse<GalleryDto>> fetchHorseGallery({
    required String horseId,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.get(
      '/profiling/horses/$horseId/gallery',
    );

    if (response.isFailure) {
      return RestResponse<GalleryDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody((Json body) {
      if (body['images'] != null) {
        return GalleryMapper.toDto(body);
      }

      return GalleryMapper.toDto(<String, dynamic>{
        'horse_id': horseId,
        'images': body['items'],
      });
    });
  }

  @override
  Future<RestResponse<GalleryDto>> updateHorseGallery({
    required String horseId,
    required GalleryDto gallery,
  }) async {
    super.setAuthHeader();
    final RestResponse<Json> response = await super.restClient.put(
      '/profiling/horses/$horseId/gallery',
      body: GalleryMapper.toJson(gallery),
    );

    if (response.isFailure) {
      return RestResponse<GalleryDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody((Json body) {
      if (body['images'] != null ||
          body['horse_id'] != null ||
          body['horseId'] != null) {
        return GalleryMapper.toDto(body);
      }

      return GalleryDto(horseId: horseId, images: gallery.images);
    });
  }
}
