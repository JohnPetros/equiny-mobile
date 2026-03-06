import 'dart:io';

import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerDocumentPickerDriver implements DocumentPickerDriver {
  @override
  Future<List<File>> pickDocuments({
    required List<String> allowedExtensions,
  }) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null) {
      return <File>[];
    }

    return result.paths
        .whereType<String>()
        .where((String path) => path.isNotEmpty)
        .map(File.new)
        .toList();
  }
}
