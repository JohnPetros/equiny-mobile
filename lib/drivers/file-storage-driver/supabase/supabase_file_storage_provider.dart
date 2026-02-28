import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/shared/interfaces/env_driver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFileStorageDriver implements FileStorageDriver {
  final EnvDriver envDriver;
  late final SupabaseClient? _supabase;
  final Dio _dio;

  SupabaseFileStorageDriver(this.envDriver, [Dio? dio]) : _dio = dio ?? Dio() {
    _supabase = _createClient();
  }

  SupabaseClient? _createClient() {
    try {
      final String url = envDriver.get('SUPABASE_URL');
      final String key = envDriver.get('SUPABASE_KEY');
      if (url.isEmpty || key.isEmpty) {
        return null;
      }
      return SupabaseClient(url, key);
    } catch (_) {
      return null;
    }
  }

  String? get _bucket {
    try {
      final String bucket = envDriver.get('SUPABASE_STORAGE_BUCKET');
      if (bucket.isEmpty) {
        return null;
      }
      return bucket;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get _client {
    final SupabaseClient? client = _supabase;
    if (client == null) {
      throw Exception('Supabase nao configurado para operacoes de storage.');
    }
    return client;
  }

  String get _requiredBucket {
    final String? bucket = _bucket;
    if ((bucket ?? '').isEmpty) {
      throw Exception('Bucket do Supabase nao configurado.');
    }
    return bucket!;
  }

  @override
  String getFileUrl(String filePath) {
    final SupabaseClient? client = _supabase;
    final String? bucket = _bucket;
    if (client == null || (bucket ?? '').isEmpty || filePath.isEmpty) {
      return '';
    }
    return client.storage.from(bucket!).getPublicUrl(filePath);
  }

  @override
  Future<void> uploadFile(File file, UploadUrlDto uploadUrl) async {
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: ${file.path}');
    }

    await _client.storage
        .from(_requiredBucket)
        .uploadToSignedUrl(
          uploadUrl.filePath,
          uploadUrl.token,
          file,
          FileOptions(contentType: _guessContentType(file.path)),
        );
  }

  @override
  Future<void> uploadFiles(
    List<File> files,
    List<UploadUrlDto> uploadUrls,
  ) async {
    if (files.length != uploadUrls.length) {
      throw ArgumentError(
        'Quantidade de arquivos (${files.length}) diferente da quantidade de URLs (${uploadUrls.length}).',
      );
    }

    await Future.wait(
      List.generate(files.length, (i) => uploadFile(files[i], uploadUrls[i])),
    );
  }

  @override
  Future<File> downloadFile(String filePath) async {
    final String fileUrl = getFileUrl(filePath);
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String fileName = filePath.split('/').last;
    final String savePath = '${documentsDir.path}/$fileName';

    await _dio.download(fileUrl, savePath);

    return File(savePath);
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.json')) return 'application/json';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';

    return 'application/octet-stream';
  }
}
