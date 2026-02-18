import 'package:equiny/core/shared/responses/rest_response.dart';

abstract class LocationService {
  Future<RestResponse<List<String>>> fetchStates();
  Future<RestResponse<List<String>>> fetchCities(String state);
}
