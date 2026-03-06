class OwnerPresenceDto {
  final String ownerId;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const OwnerPresenceDto({
    required this.ownerId,
    required this.isOnline,
    required this.lastSeenAt,
  });
}
