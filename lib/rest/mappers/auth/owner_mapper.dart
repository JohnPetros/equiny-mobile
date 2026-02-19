import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class OwnerMapper {
  static OwnerDto toDto(Json body) {
    return OwnerDto(
      id: body['id']?.toString(),
      name: body['name']?.toString() ?? '',
      email: body['email']?.toString() ?? '',
      accountId: body['account_id']?.toString() ?? '',
      avatar: body['avatar']?.toString(),
      phone: body['phone']?.toString(),
      bio: body['bio']?.toString(),
      hasCompletedOnboarding: body['has_completed_onboarding'],
    );
  }

  static Json toJson(OwnerDto owner) {
    return <String, dynamic>{
      'name': owner.name,
      'email': owner.email,
      'avatar': owner.avatar,
      'phone': owner.phone,
      'bio': owner.bio,
    };
  }
}
