import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCacheDriver implements CacheDriver {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesCacheDriver(this._sharedPreferences);

  @override
  String? get(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> set(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _sharedPreferences.remove(key);
  }
}
