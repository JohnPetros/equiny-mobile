import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileOwnerTabPlaceholderView extends StatelessWidget {
  final String message;

  const ProfileOwnerTabPlaceholderView({
    this.message = 'A aba Dono sera implementada na proxima etapa.',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppThemeColors.textSecondary),
      ),
    );
  }
}
