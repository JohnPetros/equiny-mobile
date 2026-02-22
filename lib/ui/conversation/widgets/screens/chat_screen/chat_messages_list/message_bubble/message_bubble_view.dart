import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubbleView extends StatelessWidget {
  final String message;
  final bool isMine;
  final String timeLabel;
  final bool isReadByRecipient;

  const MessageBubbleView({
    required this.message,
    required this.isMine,
    required this.timeLabel,
    required this.isReadByRecipient,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  color: presenter.textColor(isMine),
                  fontSize: AppFontSize.sm,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: isMine
                        ? AppThemeColors.border
                        : AppThemeColors.textSecondary,
                    fontSize: AppFontSize.xxs,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isReadByRecipient ? Icons.done_all : Icons.done,
                    size: AppFontSize.xs,
                    color: isReadByRecipient
                        ? AppThemeColors.border
                        : AppThemeColors.border,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
