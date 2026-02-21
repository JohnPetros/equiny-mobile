import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';

class OwnerDto {
  final String? id;
  final String name;
  final String email;
  final String accountId;
  final bool hasCompletedOnboarding;
  final ImageDto? avatar;
  final String? phone;
  final String? bio;

  const OwnerDto({
    this.id,
    required this.name,
    required this.email,
    required this.accountId,
    required this.hasCompletedOnboarding,
    this.avatar,
    this.phone,
    this.bio,
  });
}
