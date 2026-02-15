import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden.');
});

final cacheDriverProvider = Provider<CacheDriver>((ref) {
  return SharedPreferencesCacheDriver(ref.watch(sharedPreferencesProvider));
});
