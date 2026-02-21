class AttachmentDto {
  final String chatId;
  final String messageId;
  final String attachmentId;
  final String fileKind;
  final String fileName;

  const AttachmentDto({
    required this.chatId,
    required this.messageId,
    required this.attachmentId,
    required this.fileKind,
    required this.fileName,
  });
}
