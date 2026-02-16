import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class OwnerMapper {
  static OwnerDto toDto(Json body) {
    return OwnerDto(
      id: body['id']?.toString(),
      name: body['name']?.toString() ?? '',
      email: body['email']?.toString() ?? '',
      accountId: body['account_id']?.toString() ?? '',
      hasCompletedOnboarding: _readBool(body['has_completed_onboarding']),
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }
}
