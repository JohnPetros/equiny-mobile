import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PendingAttachmentItemView extends StatelessWidget {
  final PendingAttachment attachment;
  final void Function() onRemove;

  const PendingAttachmentItemView({
    required this.attachment,
    required this.onRemove,
    super.key,
  });

  bool get _isImage => attachment.kind == 'image';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppThemeColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _isImage ? Icons.image_outlined : Icons.description_outlined,
                size: AppFontSize.md,
                color: AppThemeColors.textSecondary,
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  size: AppFontSize.sm,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            attachment.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppThemeColors.textMain,
              fontSize: AppFontSize.xs,
            ),
          ),
          if (attachment.status == AttachmentUploadStatus.failed &&
              (attachment.errorMessage ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                attachment.errorMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppThemeColors.errorText,
                  fontSize: AppFontSize.xxs,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
