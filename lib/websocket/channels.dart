import 'package:equiny/core/conversation/interfaces/chat_channel.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/websocket/wsc/channels/conversation/wsc_chat_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatChannelProvider = Provider<ChatChannel>((ref) {
  final envDriver = ref.read(envDriverProvider);
  final cacheDriver = ref.read(cacheDriverProvider);
  return WscChatChannel(envDriver, cacheDriver);
});
