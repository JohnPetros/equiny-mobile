import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class RecipientFaker {
  static RecipientDto fakeDto({String? id, String? name, ImageDto? avatar}) {
    return RecipientDto(
      id: id ?? 'recipient-id',
      name: name ?? 'Recipient Name',
      avatar: avatar,
    );
  }
}
