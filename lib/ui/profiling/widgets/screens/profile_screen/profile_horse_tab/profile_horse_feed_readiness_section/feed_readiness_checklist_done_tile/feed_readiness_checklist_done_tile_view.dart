import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedReadinessChecklistDoneTileView extends StatelessWidget {
  final String text;
  final bool done;

  const FeedReadinessChecklistDoneTileView({
    required this.text,
    required this.done,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = done
        ? AppThemeColors.textSecondary
        : AppThemeColors.textMain;

    return Row(
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF26213D),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF51437F)),
          ),
          child: const Icon(
            Icons.check,
            size: 14,
            color: AppThemeColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              decoration: done
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: textColor,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }
}
