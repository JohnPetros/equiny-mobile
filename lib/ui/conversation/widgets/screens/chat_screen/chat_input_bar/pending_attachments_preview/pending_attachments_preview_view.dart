import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/pending_attachments_preview/pending_attachment_item/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PendingAttachmentsPreviewView extends StatelessWidget {
  final List<PendingAttachment> attachments;
  final void Function(String localId) onRemove;

  const PendingAttachmentsPreviewView({
    required this.attachments,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          itemBuilder: (BuildContext context, int index) {
            final PendingAttachment attachment = attachments[index];
            return PendingAttachmentItem(
              attachment: attachment,
              onRemove: () => onRemove(attachment.localId),
            );
          },
        ),
      ),
    );
  }
}
