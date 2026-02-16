import 'package:equiny/core/auth/interfaces/auth_service.dart' as auth_service;
import 'package:equiny/core/auth/dtos/jwt_dto.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/mappers/auth/jwt_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class AuthService extends Service implements auth_service.AuthService {
  AuthService(super.restClient);

  @override
  Future<RestResponse<JwtDto>> signIn({
    required String accountEmail,
    required String accountPassword,
  }) async {
    final RestResponse<Json> response = await super.restClient.post(
      '/auth/sign-in',
      body: <String, dynamic>{
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

    final jwtDto = JwtMapper.toDto(response.body);

    return RestResponse<JwtDto>(body: jwtDto, statusCode: response.statusCode);
  }

  @override
  Future<RestResponse<JwtDto>> signUp({
    required String ownerName,
    required String accountEmail,
    required String accountPassword,
  }) async {
    final RestResponse<Json> response = await super.restClient.post(
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
    final jwtDto = JwtMapper.toDto(response.body);

    return RestResponse<JwtDto>(body: jwtDto, statusCode: response.statusCode);
  }
}
