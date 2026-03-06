import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxChatListItemPresenter {
  String truncatePreview(String content, {int maxLength = 35}) {
    final String trimmed = content.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }

    return '${trimmed.substring(0, maxLength)}...';
  }

  bool shouldShowUnreadBadge(int unreadCount) {
    return unreadCount > 0;
  }

  bool shouldShowReadCheck(ChatDto chat, String currentUserId) {
    if (chat.unreadCount > 0) {
      return false;
    }

    if (currentUserId.trim().isNotEmpty) {
      return chat.lastMessage.senderId == currentUserId;
    }

    final String recipientId = chat.recipient.id ?? '';
    if (recipientId.isEmpty) {
      return false;
    }

    return chat.lastMessage.senderId != recipientId &&
        chat.lastMessage.receiverId == recipientId;
  }
}

final inboxChatListItemPresenterProvider =
    Provider.autoDispose<InboxChatListItemPresenter>((ref) {
      return InboxChatListItemPresenter();
    });
