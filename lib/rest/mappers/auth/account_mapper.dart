import 'package:equiny/core/auth/dtos/account_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class AccountMapper {
  static AccountDto toDto(Json body) {
    return AccountDto(
      id: body['id']?.toString(),
      email: body['email']?.toString() ?? '',
      isVerified: body['is_verified']?.toString() ?? 'false',
    );
  }
}
