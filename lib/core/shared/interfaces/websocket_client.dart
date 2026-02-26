import 'package:equiny/core/shared/types/json.dart';

abstract class WebSocketClient {
  Future<void> connect(String url);
  Future<void> disconnect();
  void Function() onData(Function(Json data) callback);
  Future<void> send(Json data);
}
