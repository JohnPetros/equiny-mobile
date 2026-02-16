import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/rest/dio/dio_rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restClientProvider = Provider<RestClient>((ref) {
  final envDriver = ref.watch(envDriverProvider);
  final cacheDriver = ref.watch(cacheDriverProvider);
  final restClient = DioRestClient(cacheDriver);
  restClient.setBaseUrl(envDriver.get('EQUINY_SERVICE_URL'));
  return restClient;
});
