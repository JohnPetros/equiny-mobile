abstract class InternetConnectionDriver {
  Future<bool> hasInternetAccess();
  Stream<bool> onStatusChange();
}
