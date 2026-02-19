import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OptionCardView extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const OptionCardView({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppThemeColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppThemeColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppThemeColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.textMain,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppThemeColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
