import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/auth/owner_mapper.dart';

class JwtMapper {
  static JwtDto toDto(Json body) {
    final Json ownerBody = _readMap(body['owner']);
    return JwtDto(
      accessToken: body['access_token']?.toString() ?? '',
      owner: ownerBody.isEmpty ? null : OwnerMapper.toDto(ownerBody),
    );
  }

  static Json _readMap(dynamic value) {
    if (value is Json) {
      return value;
    }
    return <String, dynamic>{};
  }
}
