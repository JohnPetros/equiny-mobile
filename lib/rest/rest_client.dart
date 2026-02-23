import 'package:equiny/core/shared/constants/env_keys.dart';
import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/rest/dio/dio_rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restClientProvider = Provider<RestClient>((ref) {
  final envDriver = ref.read(envDriverProvider);
  final restClient = DioRestClient();
  restClient.setBaseUrl(envDriver.get(EnvKeys.equinyRestUrl));
  return restClient;
});
