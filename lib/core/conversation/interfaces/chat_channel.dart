import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/shared/interfaces/channel.dart';

abstract class ChatChannel extends Channel {
  Future<void> connect(String chatId);

  Future<void> sendMessage(MessageDto message);

  void listen({
    required void Function(MessageDto message) onMessageReceived,
    required void Function() onError,
    required void Function() onClose,
  });
}
