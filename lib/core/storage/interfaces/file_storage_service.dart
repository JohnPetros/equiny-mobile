import 'dart:io';

import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class FileStorageService {
  Future<RestResponse<List<ImageDto>>> uploadImageFiles({
    required List<File> files,
  });
}
