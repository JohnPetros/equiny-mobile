import 'package:equiny/websocket/channels/conversation_channel.dart';
import 'package:equiny/websocket/channels/profiling_channel.dart';
import 'package:equiny/websocket/websocket_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationChannelProvider = Provider<ConversationChannel>((ref) {
  final websocketClient = ref.read(websocketClientProvider);
  return ConversationChannel(websocketClient);
});

final profilingChannelProvider = Provider<ProfilingChannel>((ref) {
  final websocketClient = ref.read(websocketClientProvider);
  return ProfilingChannel(websocketClient);
});
