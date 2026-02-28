import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AttachmentFailedItemView extends StatelessWidget {
  final String name;
  final void Function() onRetry;

  const AttachmentFailedItemView({
    required this.name,
    required this.onRetry,
    super.key,
  });

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
