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
    if (!stateCodes.containsKey(state)) {
      return RestResponse<List<String>>(
        statusCode: HttpStatus.badRequest,
        errorMessage: 'State not found',
      );
    }
    final String stateCode = stateCodes[state]!;
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
}
