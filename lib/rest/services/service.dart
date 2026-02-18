import 'package:equiny/core/shared/interfaces/rest_client.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';

abstract class Service {
  final RestClient restClient;
  final CacheDriver _cacheDriver;

  Service(this.restClient, this._cacheDriver);

  void setAuthHeader() async {
    final accessToken = _cacheDriver.get(CacheKeys.accessToken);
    if (accessToken != null) {
      restClient.setHeader('Authorization', 'Bearer $accessToken');
    }
  }
}
