import 'package:equiny/core/auth/dtos/jwt_dto.dart';

class JwtDtoFaker {
  static JwtDto fakeDto({String? accessToken}) {
    return JwtDto(accessToken: accessToken ?? 'fake-access-token');
  }

  static List<JwtDto> fakeManyDto({int length = 2}) {
    return List<JwtDto>.generate(
      length,
      (int index) => fakeDto(accessToken: 'fake-access-token-$index'),
    );
  }
}
