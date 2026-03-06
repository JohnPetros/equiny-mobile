import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AttachmentImageItemView extends StatelessWidget {
  final String name;
  final String resolvedUrl;
  final void Function(String url) onOpenImage;

  const AttachmentImageItemView({
    required this.name,
    required this.resolvedUrl,
    required this.onOpenImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resolvedUrl.isEmpty ? null : () => onOpenImage(resolvedUrl),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppThemeColors.primary, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: resolvedUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppThemeColors.textSecondary,
                        size: 32,
                      ),
                    )
                  : Image.network(resolvedUrl, fit: BoxFit.cover),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: 6,
              ),
              color: AppThemeColors.surface,
              child: Row(
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: AppThemeColors.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppThemeColors.textSecondary,
                        fontSize: AppFontSize.xxs,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
