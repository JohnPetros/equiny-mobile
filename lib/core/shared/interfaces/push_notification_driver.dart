abstract class PushNotificationDriver {
  Future<bool> requestPermission({bool fallbackToSettings = true});

  Future<void> register({required String ownerId});

  Future<void> unregister();
}
