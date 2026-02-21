import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_header/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class InboxScreenContentView extends StatelessWidget {
  final InboxScreenPresenter presenter;
  final void Function(ChatDto item) onTapItem;

  const InboxScreenContentView({
    required this.presenter,
    required this.onTapItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: AppSpacing.xs,
              ),
              child: InboxHeader(
                title: 'Conversas',
                unreadCount: presenter.unreadConversationsCount.value,
              ),
            ),
            InboxChatList(
              items: presenter.sortedChats.value,
              onTapItem: onTapItem,
            ),
          ],
        ),
      );
    });
  }
}
