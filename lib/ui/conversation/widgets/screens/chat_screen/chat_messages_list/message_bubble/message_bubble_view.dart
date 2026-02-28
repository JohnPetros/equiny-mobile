import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubbleView extends StatelessWidget {
  final String message;
  final bool isMine;
  final String timeLabel;
  final bool isReadByRecipient;
  final List<MessageAttachmentDto> attachments;
  final Map<String, AttachmentUploadStatus> uploadStatusMap;
  final String Function(String key) resolveFileUrl;
  final void Function(String key) onRetryAttachment;
  final void Function(String url) onOpenImage;

  const MessageBubbleView({
    required this.message,
    required this.isMine,
    required this.timeLabel,
    required this.isReadByRecipient,
    this.attachments = const <MessageAttachmentDto>[],
    this.uploadStatusMap = const <String, AttachmentUploadStatus>{},
    required this.resolveFileUrl,
    required this.onRetryAttachment,
    required this.onOpenImage,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (message.trim().isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: presenter.textColor(isMine),
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                  MessageAttachmentList(
                    attachments: attachments,
                    uploadStatusMap: uploadStatusMap,
                    resolveFileUrl: resolveFileUrl,
                    onRetry: onRetryAttachment,
                    onOpenImage: onOpenImage,
                  ),
                ],
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
