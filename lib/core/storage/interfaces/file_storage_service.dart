import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';

abstract class FileStorageService {
  Future<RestResponse<List<UploadUrlDto>>> generateUploadUrlsForAttachments({
    required List<AttachmentDto> attachments,
  });
  Future<RestResponse<List<UploadUrlDto>>> generateUploadUrlsForHorseGallery({
    required String horseId,
    required List<String> imagesNames,
  });
  Future<RestResponse<UploadUrlDto>> generateUploadUrlForOwnerAvatar({
    required String ownerId,
    required String fileName,
  });
}
