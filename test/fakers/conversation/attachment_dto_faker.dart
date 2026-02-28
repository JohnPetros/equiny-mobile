import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';

class AttachmentDtoFaker {
  static MessageAttachmentDto fakeDto({
    String? kind,
    String? key,
    String? name,
    double? size,
  }) {
    return MessageAttachmentDto(
      kind: kind ?? 'image',
      key: key ?? 'attachments/chat-id/msg-id/image.jpg',
      name: name ?? 'image.jpg',
      size: size ?? 1024,
    );
  }

  static List<MessageAttachmentDto> fakeManyDto({int length = 2}) {
    return List<MessageAttachmentDto>.generate(
      length,
      (int index) => fakeDto(
        key: 'attachments/chat-id/msg-id/image-$index.jpg',
        name: 'image-$index.jpg',
      ),
    );
  }

  static MessageAttachmentDto fakePdfDto({
    String? key,
    String? name,
    double? size,
  }) {
    return MessageAttachmentDto(
      kind: 'pdf',
      key: key ?? 'attachments/chat-id/msg-id/document.pdf',
      name: name ?? 'document.pdf',
      size: size ?? 2048,
    );
  }

  static MessageAttachmentDto fakeDocxDto({
    String? key,
    String? name,
    double? size,
  }) {
    return MessageAttachmentDto(
      kind: 'docx',
      key: key ?? 'attachments/chat-id/msg-id/document.docx',
      name: name ?? 'document.docx',
      size: size ?? 1536,
    );
  }

  static MessageAttachmentDto fakeTxtDto({
    String? key,
    String? name,
    double? size,
  }) {
    return MessageAttachmentDto(
      kind: 'txt',
      key: key ?? 'attachments/chat-id/msg-id/notes.txt',
      name: name ?? 'notes.txt',
      size: size ?? 512,
    );
  }
}
