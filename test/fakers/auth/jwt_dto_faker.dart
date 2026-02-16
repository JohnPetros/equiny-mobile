import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';

class JwtDtoFaker {
  static JwtDto fakeDto({String? accessToken, OwnerDto? owner}) {
    return JwtDto(
      accessToken: accessToken ?? 'fake-access-token',
      owner: owner,
    );
  }

  static List<JwtDto> fakeManyDto({int length = 2}) {
    return List<JwtDto>.generate(
      length,
      (int index) => fakeDto(accessToken: 'fake-access-token-$index'),
    );
  }
}
