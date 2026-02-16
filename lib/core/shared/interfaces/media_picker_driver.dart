import 'dart:io';

abstract class MediaPickerDriver {
  Future<List<File>> pickImages({required int maxImages});
}
