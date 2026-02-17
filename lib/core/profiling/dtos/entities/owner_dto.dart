class OwnerDto {
  final String? id;
  final String name;
  final String email;
  final String accountId;
  final bool hasCompletedOnboarding;
  final String? phone;
  final String? bio;

  const OwnerDto({
    this.id,
    required this.name,
    required this.email,
    required this.accountId,
    required this.hasCompletedOnboarding,
    this.phone,
    this.bio,
  });
}
