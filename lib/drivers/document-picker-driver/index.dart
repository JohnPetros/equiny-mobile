import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:equiny/drivers/document-picker-driver/file-picker/file_picker_document_picker_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentPickerDriverProvider = Provider<DocumentPickerDriver>((ref) {
  return FilePickerDocumentPickerDriver();
});
