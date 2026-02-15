import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCacheDriver implements CacheDriver {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesCacheDriver(this._sharedPreferences);

  @override
  void delete(String key) {
    _sharedPreferences.remove(key);
  }

  @override
  String? get(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  void set(String key, String value) {
    _sharedPreferences.setString(key, value);
  }
}
