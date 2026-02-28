import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_document_item/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_failed_item/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_image_item/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_loading_item/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/message_attachment_item_presenter.dart';
import 'package:flutter/material.dart';

class MessageAttachmentItemView extends StatelessWidget {
  final MessageAttachmentDto attachment;
  final AttachmentUploadStatus status;
  final String resolvedUrl;
  final void Function(String key) onRetry;
  final void Function(String url) onOpenImage;

  const MessageAttachmentItemView({
    required this.attachment,
    required this.status,
    required this.resolvedUrl,
    required this.onRetry,
    required this.onOpenImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final presenter = MessageAttachmentItemPresenter();

    switch (status) {
      case AttachmentUploadStatus.sending:
        return AttachmentLoadingItem(name: attachment.name);
      case AttachmentUploadStatus.failed:
        return AttachmentFailedItem(
          name: attachment.name,
          onRetry: () => onRetry(attachment.key),
        );
      case AttachmentUploadStatus.ready:
        if (presenter.isImage(attachment.kind)) {
          return AttachmentImageItem(
            name: attachment.name,
            resolvedUrl: resolvedUrl,
            onOpenImage: onOpenImage,
          );
        }

        if (presenter.isDocument(attachment.kind)) {
          final style = presenter.documentStyleFromExtension(attachment.name);
          final sizeLabel = presenter.formatFileSize(attachment.size);
          final subtitle = sizeLabel.isNotEmpty
              ? '$sizeLabel • ${style.label}'
              : style.label;

          return AttachmentDocumentItem(
            icon: style.icon,
            iconColor: style.iconColor,
            iconBackground: style.iconBackground,
            name: attachment.name,
            subtitle: subtitle,
            filePath: attachment.key,
          );
        }

        return const SizedBox.shrink();
    }
  }
}
