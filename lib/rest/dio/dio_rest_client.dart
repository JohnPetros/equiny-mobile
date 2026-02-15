import 'package:dio/dio.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/shared/interfaces/rest_client.dart';

class DioRestClient implements RestClient {
  final Dio _dio;

  DioRestClient([Dio? dio]) : _dio = dio ?? Dio();

  @override
  Future<RestResponse<Json>> get(String path, {Json? queryParams}) async {
    return _send(() => _dio.get(path, queryParameters: queryParams));
  }

  @override
  Future<RestResponse<Json>> post(
    String path, {
    Json? body,
    Json? queryParams,
  }) async {
    return _send(
      () => _dio.post(path, data: body, queryParameters: queryParams),
    );
  }

  @override
  Future<RestResponse<Json>> put(
    String path, {
    Json? body,
    Json? queryParams,
  }) async {
    return _send(
      () => _dio.put(path, data: body, queryParameters: queryParams),
    );
  }

  @override
  Future<RestResponse<Json>> delete(
    String path, {
    Json? body,
    Json? queryParams,
  }) async {
    return _send(
      () => _dio.delete(path, data: body, queryParameters: queryParams),
    );
  }

  @override
  String getBaseUrl() {
    return _dio.options.baseUrl;
  }

  @override
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  @override
  void setHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  Future<RestResponse<Json>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      final dynamic body = response.data;
      return RestResponse<Json>(
        body: body is Json ? body : <String, dynamic>{},
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      String? errorMessage;
      if (data is Json &&
          data['title'] is String &&
          data['message'] is String) {
        errorMessage = data['message'] as String;
      } else {
        errorMessage = error.message;
      }
      return RestResponse<Json>(
        statusCode: error.response?.statusCode,
        errorMessage: errorMessage,
      );
    } catch (_) {
      return RestResponse<Json>(
        statusCode: 500,
        errorMessage: 'Erro inesperado na requisicao.',
      );
    }
  }
}
