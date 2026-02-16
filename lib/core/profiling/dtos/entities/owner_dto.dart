class OwnerDto {
  final String? id;
  final String name;
  final String email;
  final String accountId;
  final bool hasCompletedOnboarding;

  const OwnerDto({
    this.id,
    required this.name,
    required this.email,
    required this.accountId,
    required this.hasCompletedOnboarding,
  });
}
