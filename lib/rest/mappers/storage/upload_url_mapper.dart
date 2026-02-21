import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';

class UploadUrlMapper {
  static UploadUrlDto toDto(Json body) {
    return UploadUrlDto(
      url: body['url']?.toString() ?? '',
      token: body['token']?.toString() ?? '',
      filePath: body['file_path']?.toString() ?? '',
    );
  }

  static List<UploadUrlDto> toDtoList(Json body) {
    final dynamic data = body['items'];
    final List<dynamic> itemsRaw;
    if (data is List<dynamic>) {
      itemsRaw = data;
    } else {
      itemsRaw = <dynamic>[];
    }

    return itemsRaw.map((dynamic item) {
      final Json map = item is Json ? item : <String, dynamic>{};
      return UploadUrlDto(
        url: map['url']?.toString() ?? '',
        token: map['token']?.toString() ?? '',
        filePath: map['file_path']?.toString() ?? '',
      );
    }).toList();
  }
}
