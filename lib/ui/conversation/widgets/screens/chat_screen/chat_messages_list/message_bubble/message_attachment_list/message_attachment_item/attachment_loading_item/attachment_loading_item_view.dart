import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AttachmentLoadingItemView extends StatelessWidget {
  final String name;

  const AttachmentLoadingItemView({required this.name, super.key});

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
