import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedReadinessChecklistPendingTileView extends StatelessWidget {
  final String text;
  final bool highlighted;

  const FeedReadinessChecklistPendingTileView({
    required this.text,
    required this.highlighted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool yellow = highlighted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: yellow ? const Color(0xFF28210B) : const Color(0xFF1D202A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: yellow ? const Color(0xFF5B4700) : const Color(0xFF2C3040),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: yellow ? const Color(0xFF5E4700) : const Color(0xFF2C3040),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              Icons.priority_high_rounded,
              size: 15,
              color: yellow
                  ? const Color(0xFFF6BE00)
                  : AppThemeColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: yellow
                    ? const Color(0xFFF4C324)
                    : AppThemeColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: yellow
                ? const Color(0xFFF4C324)
                : AppThemeColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
