import 'package:equiny/core/auth/dtos/jwt_dto.dart';

class JwtDtoFaker {
  static JwtDto create({String? accessToken}) {
    return JwtDto(accessToken: accessToken ?? 'fake-access-token');
  }
}
