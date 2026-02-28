import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/index.dart';
import 'package:flutter/material.dart';

class MessageAttachmentListView extends StatelessWidget {
  final List<MessageAttachmentDto> attachments;
  final Map<String, AttachmentUploadStatus> uploadStatusMap;
  final String Function(String key) resolveFileUrl;
  final void Function(String key) onRetry;
  final void Function(String url) onOpenImage;

  const MessageAttachmentListView({
    required this.attachments,
    required this.uploadStatusMap,
    required this.resolveFileUrl,
    required this.onRetry,
    required this.onOpenImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments.map((MessageAttachmentDto attachment) {
        final AttachmentUploadStatus status =
            uploadStatusMap[attachment.key] ?? AttachmentUploadStatus.ready;
        final String resolvedUrl = resolveFileUrl(attachment.key);

        return MessageAttachmentItem(
          attachment: attachment,
          status: status,
          resolvedUrl: resolvedUrl,
          onRetry: onRetry,
          onOpenImage: onOpenImage,
        );
      }).toList(),
    );
  }
}
