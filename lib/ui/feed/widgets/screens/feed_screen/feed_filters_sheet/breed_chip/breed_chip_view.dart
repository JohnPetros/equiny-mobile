import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BreedChipView extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const BreedChipView({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppThemeColors.primary
              : AppThemeColors.inputBackground,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? null
              : Border.all(color: AppThemeColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _capitalize(label),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF222026)
                    : AppThemeColors.textSecondary,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.close,
                size: 14,
                color: const Color(0xFF222026).withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
