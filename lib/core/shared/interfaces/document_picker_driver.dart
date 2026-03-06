import 'dart:io';

abstract class DocumentPickerDriver {
  Future<List<File>> pickDocuments({required List<String> allowedExtensions});
}
