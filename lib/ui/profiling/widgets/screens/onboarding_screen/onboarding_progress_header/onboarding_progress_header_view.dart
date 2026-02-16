import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingProgressHeaderView extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;

  const OnboardingProgressHeaderView({
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int safeTotalSteps = totalSteps <= 0 ? 1 : totalSteps;
    final int safeStepIndex = stepIndex < 0 ? 0 : stepIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppThemeColors.border),
              ),
              child: const Icon(
                Icons.pets,
                color: AppThemeColors.primary,
                size: 20,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppThemeColors.border),
              ),
              child: Text(
                'Etapa ${safeStepIndex + 1} de $safeTotalSteps',
                style: const TextStyle(
                  color: AppThemeColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: const TextStyle(
            color: AppThemeColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        if (subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: List<Widget>.generate(safeTotalSteps, (int index) {
            final bool isActive = index <= safeStepIndex;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index == safeTotalSteps - 1 ? 0 : 6,
                ),
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppThemeColors.primary
                      : AppThemeColors.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
