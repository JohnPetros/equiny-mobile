class MessageAttachmentDto {
  final String kind;
  final String key;
  final String name;
  final double size;

  const MessageAttachmentDto({
    required this.kind,
    required this.key,
    required this.name,
    required this.size,
  });
}
