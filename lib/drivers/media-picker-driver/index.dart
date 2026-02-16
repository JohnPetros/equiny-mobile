import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaPickerDriverProvider = Provider<MediaPickerDriver>((ref) {
  return ImagePickerMediaPickerDriver();
});
