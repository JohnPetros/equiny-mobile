import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/shared/types/json.dart';

class JwtMapper {
  static JwtDto toDto(Json body) {
    return JwtDto(accessToken: body['accessToken']?.toString() ?? '');
  }
}
