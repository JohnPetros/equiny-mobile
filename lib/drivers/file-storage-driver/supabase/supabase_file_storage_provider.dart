import 'dart:io';

import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/shared/interfaces/env_driver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFileStorageDriver implements FileStorageDriver {
  final EnvDriver envDriver;
  late final SupabaseClient _supabase;

  SupabaseFileStorageDriver(this.envDriver) {
    _supabase = SupabaseClient(
      envDriver.get('SUPABASE_URL'),
      envDriver.get('SUPABASE_KEY'),
    );
  }

  String get _bucket => envDriver.get('SUPABASE_STORAGE_BUCKET');

  @override
  String getFileUrl(String filePath) {
    return _supabase.storage.from(_bucket).getPublicUrl(filePath);
  }

  @override
  Future<void> uploadFile(File file, UploadUrlDto uploadUrl) async {
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: ${file.path}');
    }

    await _supabase.storage
        .from(_bucket)
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
