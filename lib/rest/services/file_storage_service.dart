import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/constants/http_status_code.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart'
    as file_storage_service;
import 'package:equiny/rest/mappers/profiling/image_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class FileStorageService extends Service implements file_storage_service.FileStorageService {
  FileStorageService(super.restClient);

  @override
  Future<RestResponse<List<ImageDto>>> uploadImageFiles({
    required List<File> files,
  }) async {
    if (files.isEmpty) {
      return RestResponse<List<ImageDto>>(
        statusCode: HttpStatusCode.badRequest,
        errorMessage: 'Nenhuma imagem foi informada para upload.',
      );
    }

    final FormData formData = FormData();
    for (final File file in files) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.uri.pathSegments.last,
          ),
        ),
      );
    }

    final RestResponse<Json> response = await super.restClient.post(
      '/storage/images/upload',
      body: formData,
    );

    if (response.isFailure) {
      return RestResponse<List<ImageDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    if (response.statusCode != HttpStatusCode.created &&
        response.statusCode != HttpStatusCode.ok) {
      return RestResponse<List<ImageDto>>(
        statusCode: response.statusCode,
        errorMessage: 'Nao foi possivel enviar as imagens.',
      );
    }

    return response.mapBody(ImageMapper.toDtoList);
  }
}
