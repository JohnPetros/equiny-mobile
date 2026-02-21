import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AgeRangeSliderView extends StatelessWidget {
  final double minValue;
  final double maxValue;
  final Function(double min, double max) onChanged;

  const AgeRangeSliderView({
    required this.minValue,
    required this.maxValue,
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
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: RangeSlider(
            values: RangeValues(minValue.clamp(0, 20), maxValue.clamp(0, 20)),
            min: 0,
            max: 20,
            onChanged: (values) {
              onChanged(values.start, values.end);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 15,
                  color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '20+',
                style: TextStyle(
                  fontSize: 15,
                  color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
