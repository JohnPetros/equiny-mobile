abstract class Channel {
  Future<void> connect(Uri uri);
  Future<void> disconnect();
}
