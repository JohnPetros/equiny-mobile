import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubbleView extends StatelessWidget {
  final String message;
  final bool isMine;
  final String timeLabel;

  const MessageBubbleView({
    required this.message,
    required this.isMine,
    required this.timeLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final presenter = MessageBubblePresenter();
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: presenter.bubbleBackground(isMine),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message,
              style: TextStyle(
                color: presenter.textColor(isMine),
                fontSize: AppFontSize.sm,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              timeLabel,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: AppFontSize.xxs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
