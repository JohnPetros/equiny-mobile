import 'dart:io';

import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';

class PendingAttachment {
  final String localId;
  final File file;
  final String kind;
  final String name;
  final double size;
  final AttachmentUploadStatus status;
  final String? errorMessage;

  const PendingAttachment({
    required this.localId,
    required this.file,
    required this.kind,
    required this.name,
    required this.size,
    required this.status,
    this.errorMessage,
  });

  PendingAttachment copyWith({
    String? localId,
    File? file,
    String? kind,
    String? name,
    double? size,
    AttachmentUploadStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PendingAttachment(
      localId: localId ?? this.localId,
      file: file ?? this.file,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      size: size ?? this.size,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
