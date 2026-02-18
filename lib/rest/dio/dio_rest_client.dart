import 'package:dio/dio.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';

class DioRestClient implements RestClient {
  final Dio _dio;
  final CacheDriver _cacheDriver;

  DioRestClient(CacheDriver cacheDriver)
    : _dio = Dio(),
      _cacheDriver = cacheDriver;

  @override
  Future<RestResponse<Json>> get(String path, {Json? queryParams}) async {
    return _send(() => _dio.get(path, queryParameters: queryParams));
  }

  @override
  Future<RestResponse<Json>> post(
    String path, {
    Object? body,
    Json? queryParams,
  }) async {
    return _send(
      () => _dio.post(path, data: body, queryParameters: queryParams),
    );
  }

  @override
  Future<RestResponse<Json>> put(
    String path, {
    Object? body,
    Json? queryParams,
  }) async {
    return _send(
      () => _dio.put(path, data: body, queryParameters: queryParams),
    );
  }

  @override
  Future<RestResponse<Json>> delete(
    String path, {
    Object? body,
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
    final accessToken = _cacheDriver.get(CacheKeys.accessToken);
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
    try {
      final Response<dynamic> response = await request();
      final dynamic data = response.data;
      final Json? body = data is Json
          ? data
          : data is List
              ? <String, dynamic>{'items': data}
              : null;
      return RestResponse<Json>(body: body, statusCode: response.statusCode);
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
    } catch (error) {
      return RestResponse<Json>(
        statusCode: 500,
        errorMessage: error.toString(),
      );
    }
  }
}
