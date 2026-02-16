import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/auth/dtos/jwt_dto.dart';

abstract class AuthService {
  Future<RestResponse<JwtDto>> signIn({
    required String accountEmail,
    required String accountPassword,
  });
  Future<RestResponse<JwtDto>> signUp({
    required String ownerName,
    required String accountEmail,
    required String accountPassword,
  });
}
