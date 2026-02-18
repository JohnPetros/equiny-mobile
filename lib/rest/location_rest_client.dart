import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/rest/dio/dio_rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restClientProvider = Provider<RestClient>((ref) {
  final restClient = DioRestClient();
  restClient.setBaseUrl('https://servicodados.ibge.gov.br/api/v1');
  return restClient;
});
