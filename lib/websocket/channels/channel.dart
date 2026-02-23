import 'package:equiny/core/shared/interfaces/websocket_client.dart';
import 'package:equiny/core/shared/types/json.dart';

class Channel {
  final WebSocketClient websocketClient;

  Channel(this.websocketClient);

  (String, Json) parseEvent(Json data) {
    final String name =
        data['name']?.toString() ?? data['event']?.toString() ?? '';
    final Json payload = (data['payload'] as Json?) ??
        (data['data'] as Json?) ??
        <String, dynamic>{};

    return (name, payload);
  }
}
