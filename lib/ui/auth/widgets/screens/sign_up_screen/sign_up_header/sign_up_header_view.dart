import 'package:flutter/material.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignUpHeaderView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;

  const SignUpHeaderView({
    required this.title,
    required this.subtitle,
    required this.iconData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppThemeColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(iconData, size: 28, color: AppThemeColors.primary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppThemeColors.textMain,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppThemeColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
