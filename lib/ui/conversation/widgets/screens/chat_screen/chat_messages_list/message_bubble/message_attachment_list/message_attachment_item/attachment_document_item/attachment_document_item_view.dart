import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentDocumentItemView extends ConsumerWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String name;
  final String subtitle;
  final String filePath;

  const AttachmentDocumentItemView({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.name,
    required this.subtitle,
    required this.filePath,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String resolvedUrl = ref
        .read(fileStorageDriverProvider)
        .getFileUrl(filePath);
    final Uri? uri = resolvedUrl.isEmpty ? null : Uri.tryParse(resolvedUrl);

    return GestureDetector(
      onTap: uri == null ? null : () => launchUrl(uri),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: AppFontSize.md, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppThemeColors.textMain,
                      fontSize: AppFontSize.xs,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppThemeColors.textSecondary,
                        fontSize: AppFontSize.xxs,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
