import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MatchesHeaderView extends StatelessWidget {
  final String title;
  final int newCount;

  const MatchesHeaderView({
    required this.title,
    required this.newCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        if (newCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppThemeColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppThemeColors.primary.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              '$newCount novos',
              style: const TextStyle(
                color: AppThemeColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
