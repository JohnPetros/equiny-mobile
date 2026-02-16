import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';

class JwtDto {
  final String accessToken;
  final OwnerDto? owner;

  JwtDto({required this.accessToken, this.owner});
}
