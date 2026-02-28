import 'package:equiny/core/shared/constants/http_status_code.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/storage/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart'
    as file_storage_service;
import 'package:equiny/rest/mappers/storage/upload_url_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class FileStorageService extends Service
    implements file_storage_service.FileStorageService {
  FileStorageService(super.restClient, super._cacheDriver);

  @override
  Future<RestResponse<List<UploadUrlDto>>> generateUploadUrlsForAttachments({
    required String chatId,
    required String messageId,
    required List<StorageAttachmentDto> attachments,
  }) async {
    super.setAuthHeader();

    final RestResponse<Json> response = await super.restClient.post(
      '/storage/upload/chats/$chatId/messages/$messageId/attachments',
      body: <String, dynamic>{
        'attachments': attachments
            .map(
              (StorageAttachmentDto attachment) => <String, dynamic>{
                'kind': attachment.kind,
                'name': attachment.name,
              },
            )
            .toList(),
      },
    );

    if (response.isFailure) {
      return RestResponse<List<UploadUrlDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(UploadUrlMapper.toDtoList);
  }

  @override
  Future<RestResponse<List<UploadUrlDto>>> generateUploadUrlsForHorseGallery({
    required String horseId,
    required List<String> imagesNames,
  }) async {
    if (horseId.isEmpty) {
      return RestResponse<List<UploadUrlDto>>(
        statusCode: HttpStatusCode.badRequest,
        errorMessage: 'O id do cavalo nao foi informado.',
      );
    }

    if (imagesNames.isEmpty) {
      return RestResponse<List<UploadUrlDto>>(
        statusCode: HttpStatusCode.badRequest,
        errorMessage:
            'Nenhum nome de imagem foi informado para gerar URLs de upload.',
      );
    }

    super.setAuthHeader();

    final RestResponse<Json> response = await super.restClient.post(
      '/storage/upload/horses/$horseId/gallery',
      body: <String, dynamic>{'files_names': imagesNames},
    );

    if (response.isFailure) {
      return RestResponse<List<UploadUrlDto>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(UploadUrlMapper.toDtoList);
  }

  @override
  Future<RestResponse<UploadUrlDto>> generateUploadUrlForOwnerAvatar({
    required String ownerId,
    required String fileName,
  }) async {
    if (ownerId.isEmpty) {
      return RestResponse<UploadUrlDto>(
        statusCode: HttpStatusCode.badRequest,
        errorMessage: 'O id do dono nao foi informado.',
      );
    }

    if (fileName.isEmpty) {
      return RestResponse<UploadUrlDto>(
        statusCode: HttpStatusCode.badRequest,
        errorMessage: 'O nome do arquivo de avatar nao foi informado.',
      );
    }

    super.setAuthHeader();

    final RestResponse<Json> response = await super.restClient.post(
      '/storage/upload/owners/$ownerId/avatar',
      body: <String, dynamic>{'file_name': fileName},
    );

    if (response.isFailure) {
      return RestResponse<UploadUrlDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(UploadUrlMapper.toDto);
  }
}
