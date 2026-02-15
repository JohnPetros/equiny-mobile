import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';

abstract class RestClient {
  Future<RestResponse<Json>> get(String path, {Json? queryParams});
  Future<RestResponse<Json>> post(String path, {Json? body, Json? queryParams});
  Future<RestResponse<Json>> put(String path, {Json? body, Json? queryParams});
  Future<RestResponse<Json>> delete(
    String path, {
    Json? body,
    Json? queryParams,
  });
  String getBaseUrl();
  void setBaseUrl(String baseUrl);
  void setHeader(String key, String value);
}
