import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/auth/interfaces/auth_service.dart' as auth_service;
import 'package:equiny/core/shared/constants/http_status_code.dart';
import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/auth/mappers/jwt_mapper.dart';

class AuthService implements auth_service.AuthService {
  final RestClient _restClient;

  AuthService(this._restClient);

  @override
  Future<RestResponse<JwtDto>> signUp({
    required String ownerName,
    required String accountEmail,
    required String accountPassword,
  }) async {
    final RestResponse<Json> response = await _restClient.post(
      '/auth/sign-up',
      body: <String, dynamic>{
        'owner_name': ownerName,
        'account_email': accountEmail,
        'account_password': accountPassword,
      },
    );

    if (response.isFailure) {
      return RestResponse<JwtDto>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    if (response.statusCode != HttpStatusCode.created &&
        response.statusCode != HttpStatusCode.ok) {
      return RestResponse<JwtDto>(
        statusCode: response.statusCode,
        errorMessage: 'Nao foi possivel criar a conta.',
      );
    }

    return response.mapBody(JwtMapper.toDto);
  }
}
