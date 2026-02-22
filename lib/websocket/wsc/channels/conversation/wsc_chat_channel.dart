import 'dart:async';
import 'dart:convert';

import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/interfaces/chat_channel.dart';
import 'package:equiny/rest/mappers/conversation/message_mapper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WscChatChannel extends ChatChannel {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  @override
  Future<void> connect(Uri uri) async {
    _channel = WebSocketChannel.connect(uri);
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  Future<void> sendMessage(MessageDto message) async {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    channel.sink.add(jsonEncode(MessageMapper.toJson(message)));
  }

  @override
  void listen({
    required void Function(MessageDto message) onMessageReceived,
    required void Function() onError,
    required void Function() onClose,
  }) {
    final channel = _channel;
    if (channel == null) {
      onError();
      return;
    }

    _subscription?.cancel();
    _subscription = channel.stream.listen(
      (dynamic event) {
        if (event is String) {
          final dynamic decoded = jsonDecode(event);
          if (decoded is Map<String, dynamic>) {
            onMessageReceived(MessageMapper.toDto(decoded));
          }
          return;
        }

        if (event is Map<String, dynamic>) {
          onMessageReceived(MessageMapper.toDto(event));
        }
      },
      onError: (_) {
        onError();
      },
      onDone: onClose,
      cancelOnError: false,
    );
  }
}
