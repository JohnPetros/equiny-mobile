import 'dart:io';

import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:signals/signals.dart';

enum DocumentDownloadStatus { idle, downloading, done, failed }

class AttachmentDocumentItemPresenter {
  final FileStorageDriver _fileStorageDriver;

  final Signal<DocumentDownloadStatus> downloadStatus = signal(
    DocumentDownloadStatus.idle,
  );
  final Signal<File?> downloadedFile = signal(null);

  AttachmentDocumentItemPresenter(this._fileStorageDriver);

  bool get isDownloading =>
      downloadStatus.value == DocumentDownloadStatus.downloading;

  bool get hasFailed => downloadStatus.value == DocumentDownloadStatus.failed;

  bool get isDone => downloadStatus.value == DocumentDownloadStatus.done;

  Future<File?> download(String filePath) async {
    if (isDownloading) return null;

    downloadStatus.value = DocumentDownloadStatus.downloading;
    try {
      final File file = await _fileStorageDriver.downloadFile(filePath);
      downloadedFile.value = file;
      downloadStatus.value = DocumentDownloadStatus.done;
      return file;
    } catch (_) {
      downloadStatus.value = DocumentDownloadStatus.failed;
      return null;
    }
  }

  void resetDownload() {
    downloadStatus.value = DocumentDownloadStatus.idle;
    downloadedFile.value = null;
  }
}
