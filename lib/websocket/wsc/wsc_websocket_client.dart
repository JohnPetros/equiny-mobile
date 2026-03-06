import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:equiny/core/shared/interfaces/websocket_client.dart';
import 'package:equiny/core/shared/types/json.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WscWebSocketClient implements WebSocketClient {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final List<void Function(Json data)> _onDataCallbacks =
      <void Function(Json data)>[];

  @override
  Future<void> connect(String url) async {
    await disconnect();
    final uri = Uri.parse(url);
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel?.stream.listen((dynamic event) {
      final parsed = _parseData(event);
      if (parsed == null) return;

      for (final callback in _onDataCallbacks) {
        callback(parsed);
      }
    }, cancelOnError: false);
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }

  @override
  void Function() onData(Function(Json data) callback) {
    _onDataCallbacks.add(callback);

    return () {
      _onDataCallbacks.remove(callback);
    };
  }

  @override
  Future<void> send(Json data) async {
    _channel?.sink.add(jsonEncode(data));
  }

  Json? _parseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }

    if (data is List<int>) {
      final String decodedText = utf8.decode(data);
      return _parseData(decodedText);
    }

    if (data is Uint8List) {
      final String decodedText = utf8.decode(data);
      return _parseData(decodedText);
    }

    return null;
  }
}
