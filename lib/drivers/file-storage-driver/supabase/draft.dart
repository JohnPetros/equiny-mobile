import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/shared/interfaces/env_driver.dart';

class SupabaseFileStorageDriver implements FileStorageDriver {
  final EnvDriver envDriver;
  final Dio _dio;

  SupabaseFileStorageDriver(this.envDriver, [Dio? dio]) : _dio = dio ?? Dio();

  @override
  String getFileUrl(String filePath) {
    return '${envDriver.get('SUPABASE_STORAGE_URL')}/$filePath';
  }

  @override
  Future<void> uploadFile(File file, UploadUrlDto uploadUrl) async {
    final String uploadEndpoint = _buildUploadEndpoint(uploadUrl);

    await _dio.put<void>(
      uploadEndpoint,
      data: await file.readAsBytes(),
      options: Options(
        headers: <String, dynamic>{
          Headers.contentTypeHeader: _resolveContentType(file.path),
        },
      ),
    );
  }

  @override
  Future<void> uploadFiles(
    List<File> files,
    List<UploadUrlDto> uploadUrls,
  ) async {
    if (files.length != uploadUrls.length) {
      throw ArgumentError('files-and-upload-urls-must-have-the-same-length');
    }

    await Future.wait<void>(
      List<Future<void>>.generate(
        files.length,
        (int index) => uploadFile(files[index], uploadUrls[index]),
      ),
    );
  }

  String _buildUploadEndpoint(UploadUrlDto uploadUrl) {
    if (uploadUrl.token.isEmpty || uploadUrl.url.contains('token=')) {
      return uploadUrl.url;
    }

    final String querySeparator = uploadUrl.url.contains('?') ? '&' : '?';
    return '${uploadUrl.url}${querySeparator}token=${uploadUrl.token}';
  }

  String _resolveContentType(String path) {
    final String normalizedPath = path.toLowerCase();

    if (normalizedPath.endsWith('.png')) {
      return 'image/png';
    }

    if (normalizedPath.endsWith('.webp')) {
      return 'image/webp';
    }

    if (normalizedPath.endsWith('.heic') || normalizedPath.endsWith('.heif')) {
      return 'image/heic';
    }

    return 'image/jpeg';
  }
}
