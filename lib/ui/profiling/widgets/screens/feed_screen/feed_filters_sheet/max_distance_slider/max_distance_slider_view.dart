import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MaxDistanceSliderView extends StatelessWidget {
  final double value;
  final Function(double value) onChanged;

  const MaxDistanceSliderView({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppThemeColors.primary,
            inactiveTrackColor: AppThemeColors.inputBorder,
            thumbColor: AppThemeColors.primary,
            overlayColor: AppThemeColors.primary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.clamp(25, 500),
            min: 25,
            max: 500,
            divisions: 19,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '25 km',
              style: TextStyle(
                fontSize: 15,
                color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '500 km',
              style: TextStyle(
                fontSize: 15,
                color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
