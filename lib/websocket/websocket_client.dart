import 'package:equiny/core/shared/interfaces/websocket_client.dart';
import 'package:equiny/websocket/wsc/wsc_websocket_clientt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final websocketClientProvider = Provider<WebSocketClient>((ref) {
  final websocketClient = WscWebSocketClient();

  ref.onDispose(() {
    websocketClient.disconnect();
  });

  return websocketClient;
});
