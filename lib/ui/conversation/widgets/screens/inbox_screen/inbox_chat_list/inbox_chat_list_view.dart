import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/index.dart';
import 'package:flutter/material.dart';

class InboxChatListView extends StatelessWidget {
  final List<ChatDto> items;
  final void Function(ChatDto item) onTapItem;

  const InboxChatListView({
    required this.items,
    required this.onTapItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final ChatDto item = items[index];
        return InboxChatListItem(chat: item, onTap: () => onTapItem(item));
      },
    );
  }
}
