import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/message_attachment_item_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageAttachmentItemView extends StatelessWidget {
  final MessageAttachmentDto attachment;
  final AttachmentUploadStatus status;
  final String resolvedUrl;
  final void Function(String key) onRetry;
  final void Function(String url) onOpenDocument;
  final void Function(String url) onOpenImage;

  const MessageAttachmentItemView({
    required this.attachment,
    required this.status,
    required this.resolvedUrl,
    required this.onRetry,
    required this.onOpenDocument,
    required this.onOpenImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final presenter = MessageAttachmentItemPresenter();

    switch (status) {
      case AttachmentUploadStatus.sending:
        return _AttachmentLoadingItem(name: attachment.name);
      case AttachmentUploadStatus.failed:
        return _AttachmentFailedItem(
          name: attachment.name,
          onRetry: () => onRetry(attachment.key),
        );
      case AttachmentUploadStatus.ready:
        if (presenter.isImage(attachment.kind)) {
          return _AttachmentImageItem(
            name: attachment.name,
            resolvedUrl: resolvedUrl,
            onOpenImage: onOpenImage,
          );
        }

        return _AttachmentDocumentItem(
          icon: presenter.attachmentIconData(attachment.kind),
          iconColor: presenter.iconColor(attachment.kind),
          name: attachment.name,
          resolvedUrl: resolvedUrl,
          onOpenDocument: onOpenDocument,
        );
    }
  }
}

class _AttachmentLoadingItem extends StatelessWidget {
  final String name;

  const _AttachmentLoadingItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: AppFontSize.xs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentFailedItem extends StatelessWidget {
  final String name;
  final void Function() onRetry;

  const _AttachmentFailedItem({required this.name, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: AppFontSize.sm,
            color: AppThemeColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppThemeColors.errorText,
                fontSize: AppFontSize.xs,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}

class _AttachmentImageItem extends StatelessWidget {
  final String name;
  final String resolvedUrl;
  final void Function(String url) onOpenImage;

  const _AttachmentImageItem({
    required this.name,
    required this.resolvedUrl,
    required this.onOpenImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resolvedUrl.isEmpty ? null : () => onOpenImage(resolvedUrl),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        width: 150,
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: resolvedUrl.isEmpty
            ? Center(
                child: Text(
                  name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeColors.textSecondary,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              )
            : Image.network(resolvedUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _AttachmentDocumentItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String resolvedUrl;
  final void Function(String url) onOpenDocument;

  const _AttachmentDocumentItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.resolvedUrl,
    required this.onOpenDocument,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resolvedUrl.isEmpty ? null : () => onOpenDocument(resolvedUrl),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: AppFontSize.md, color: iconColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppThemeColors.textMain,
                  fontSize: AppFontSize.xs,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
