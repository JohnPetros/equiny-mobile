import 'dart:io';

import 'package:equiny/core/shared/interfaces/location_service.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/rest/ibge/constants/states.dart';

import 'package:equiny/rest/ibge/mappers/ibge_location_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class IbgeLocationService extends Service implements LocationService {
  IbgeLocationService(super.restClient, super._cacheDriver);

  @override
  Future<RestResponse<List<String>>> fetchStates() async {
    final RestResponse<Json> response = await super.restClient.get(
      '/localidades/estados',
      queryParams: <String, dynamic>{'orderBy': 'nome'},
    );

    if (response.isFailure) {
      return RestResponse<List<String>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(IbgeLocationMapper.toStateList);
  }

  @override
  Future<RestResponse<List<String>>> fetchCities(String state) async {
    final String normalizedState = _normalizeStateName(state);
    final String matchedState = stateCodes.keys.firstWhere(
      (String candidate) => _normalizeStateName(candidate) == normalizedState,
      orElse: () => '',
    );

    if (matchedState.isEmpty) {
      return RestResponse<List<String>>(
        statusCode: HttpStatus.badRequest,
        errorMessage: 'State not found',
      );
    }

    final String stateCode = stateCodes[matchedState]!;
    final RestResponse<Json> response = await super.restClient.get(
      '/localidades/estados/$stateCode/municipios',
    );

    if (response.isFailure) {
      return RestResponse<List<String>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(IbgeLocationMapper.toCityList);
  }

  String _normalizeStateName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}
