import 'dart:io';

import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';

class ChatAttachmentPickerPresenter {
  final MediaPickerDriver _mediaPickerDriver;
  final DocumentPickerDriver _documentPickerDriver;

  static const int maxAttachmentsPerMessage = 3;
  static const int imageMaxBytes = 2 * 1024 * 1024;
  static const int pdfMaxBytes = 3 * 1024 * 1024;
  static const int docxMaxBytes = 2 * 1024 * 1024;
  static const int txtMaxBytes = 100 * 1024;
  static const List<String> allowedDocumentExtensions = <String>[
    'pdf',
    'docx',
    'txt',
  ];

  const ChatAttachmentPickerPresenter(
    this._mediaPickerDriver,
    this._documentPickerDriver,
  );

  Future<List<PendingAttachment>> pickImages({
    required int remainingSlots,
  }) async {
    if (remainingSlots <= 0) {
      return <PendingAttachment>[];
    }

    final List<File> files = await _mediaPickerDriver.pickImages(
      maxImages: remainingSlots,
    );
    return _mapFilesToPending(files: files, fallbackKind: 'image');
  }

  Future<List<PendingAttachment>> pickDocuments({
    required int remainingSlots,
  }) async {
    if (remainingSlots <= 0) {
      return <PendingAttachment>[];
    }

    final List<File> files = await _documentPickerDriver.pickDocuments(
      allowedExtensions: allowedDocumentExtensions,
    );

    return _mapFilesToPending(files: files.take(remainingSlots).toList());
  }

  String? validateFileSize(File file, String kind) {
    final int bytes = file.lengthSync();

    if (kind == 'image' && bytes > imageMaxBytes) {
      return 'Imagem excede 2 MB.';
    }
    if (kind == 'pdf' && bytes > pdfMaxBytes) {
      return 'PDF excede 3 MB.';
    }
    if (kind == 'docx' && bytes > docxMaxBytes) {
      return 'DOCX excede 2 MB.';
    }
    if (kind == 'txt' && bytes > txtMaxBytes) {
      return 'TXT excede 100 KB.';
    }

    return null;
  }

  List<PendingAttachment> _mapFilesToPending({
    required List<File> files,
    String? fallbackKind,
  }) {
    final int now = DateTime.now().microsecondsSinceEpoch;
    return files.asMap().entries.map((entry) {
      final int index = entry.key;
      final File file = entry.value;
      final String fileName = file.path.split(Platform.pathSeparator).last;
      final String kind = fallbackKind ?? _resolveKindFromFileName(fileName);
      final String? errorMessage = validateFileSize(file, kind);

      return PendingAttachment(
        localId: '${now}_$index',
        file: file,
        kind: kind,
        name: fileName,
        size: file.lengthSync().toDouble(),
        status: errorMessage == null
            ? AttachmentUploadStatus.ready
            : AttachmentUploadStatus.failed,
        errorMessage: errorMessage,
      );
    }).toList();
  }

  String _resolveKindFromFileName(String fileName) {
    final String lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.heic')) {
      return 'image';
    }

    for (final String extension in allowedDocumentExtensions) {
      if (lower.endsWith('.$extension')) {
        return extension;
      }
    }

    return 'document';
  }
}
