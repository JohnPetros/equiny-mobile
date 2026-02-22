import 'package:equiny/core/conversation/interfaces/chat_channel.dart';
import 'package:equiny/websocket/wsc/channels/conversation/wsc_chat_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wscChatChannelProvider = Provider.family<ChatChannel, String>((ref, _) {
  return WscChatChannel();
});
