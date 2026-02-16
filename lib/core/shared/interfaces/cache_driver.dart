abstract class CacheDriver {
  String? get(String key);
  Future<void> set(String key, String value);
  Future<void> delete(String key);
}
