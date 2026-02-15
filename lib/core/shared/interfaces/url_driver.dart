abstract class UrlDriver {
  Future<void> launch(Uri uri);
  Future<bool> canLaunch(Uri uri);
}
