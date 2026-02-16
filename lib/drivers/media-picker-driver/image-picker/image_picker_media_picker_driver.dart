import 'dart:io';

import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerMediaPickerDriver implements MediaPickerDriver {
  final ImagePicker _imagePicker;

  ImagePickerMediaPickerDriver([ImagePicker? imagePicker])
    : _imagePicker = imagePicker ?? ImagePicker();

  @override
  Future<List<File>> pickImages({required int maxImages}) async {
    final int safeMaxImages = maxImages <= 0 ? 1 : maxImages;

    List<XFile> selectedFiles = <XFile>[];

    if (safeMaxImages == 1) {
      selectedFiles = await _pickSingleImage();
    } else {
      selectedFiles = await _pickMultipleImages(safeMaxImages);
    }

    return selectedFiles.map((XFile file) => File(file.path)).toList();
  }

  Future<List<XFile>> _pickMultipleImages(int maxImages) async {
    try {
      return await _imagePicker.pickMultiImage(
        limit: maxImages,
        imageQuality: 90,
      );
    } on Exception {
      return _pickSingleImage();
    }
  }

  Future<List<XFile>> _pickSingleImage() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file == null) {
        return <XFile>[];
      }

      return <XFile>[file];
    } on Exception {
      throw UnsupportedError('media-picker-plugin-not-available');
    }
  }
}
