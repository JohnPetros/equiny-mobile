import 'package:equiny/core/shared/interfaces/location_service.dart'
    as location_service;
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';

import 'package:equiny/rest/mappers/location/location_mapper.dart';
import 'package:equiny/rest/services/service.dart';

class LocationService extends Service
    implements location_service.LocationService {
  LocationService(super.restClient) {
    super.restClient.setBaseUrl('https://servicodados.ibge.gov.br/api/v1');
  }

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

    return response.mapBody(LocationMapper.toStateList);
  }

  @override
  Future<RestResponse<List<String>>> fetchCities(String state) async {
    final RestResponse<Json> response = await super.restClient.get(
      '/localidades/estados/$state/municipios',
    );

    if (response.isFailure) {
      return RestResponse<List<String>>(
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    }

    return response.mapBody(LocationMapper.toCityList);
  }
}

