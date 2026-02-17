import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SexButtonView extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SexButtonView({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? AppThemeColors.primary
              : AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppThemeColors.primary
                : AppThemeColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected
                ? AppThemeColors.background
                : AppThemeColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
