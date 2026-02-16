import 'package:flutter/material.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';

class OnboardingActionsView extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool canAdvance;
  final bool canFinish;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const OnboardingActionsView({
    required this.isFirstStep,
    required this.isLastStep,
    required this.canAdvance,
    required this.canFinish,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 48,
          width: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppThemeColors.border),
            ),
            child: IconButton(
              onPressed: isLoading || isFirstStep ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              color: AppThemeColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : isLastStep
                  ? (canFinish ? onFinish : null)
                  : (canAdvance ? onNext : null),
              icon: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(isLastStep ? 'Concluir cadastro' : 'Avancar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
