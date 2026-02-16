import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class OnboardingStepHeightView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;

  const OnboardingStepHeightView({
    required this.form,
    required this.submitAttempted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppThemeColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ReactiveForm(
        formGroup: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Qual e a altura dele?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Informe a altura aproximada em metros.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ReactiveValueListenableBuilder<double>(
              formControlName: 'height',
              builder:
                  (
                    BuildContext context,
                    AbstractControl<double> control,
                    Widget? child,
                  ) {
                    final double height = (control.value ?? 1.5).clamp(
                      0.5,
                      3.0,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppThemeColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppThemeColors.border),
                          ),
                          child: Text(
                            '${height.toStringAsFixed(2)} m',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppThemeColors.textMain,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppThemeColors.primary,
                            inactiveTrackColor: AppThemeColors.border,
                            thumbColor: AppThemeColors.primary,
                            overlayColor: AppThemeColors.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: height,
                            min: 0.5,
                            max: 3.0,
                            divisions: 50,
                            onChanged: (double value) {
                              form.control('height').value = value;
                              form.control('height').markAsTouched();
                            },
                          ),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '0.50 m',
                              style: TextStyle(
                                color: AppThemeColors.textSecondary,
                              ),
                            ),
                            Text(
                              '3.00 m',
                              style: TextStyle(
                                color: AppThemeColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
            ),
            ReactiveFormConsumer(
              builder:
                  (BuildContext context, FormGroup formGroup, Widget? child) {
                    final bool hasError =
                        form.control('height').invalid &&
                        (form.control('height').touched || submitAttempted);

                    if (!hasError) {
                      return const SizedBox.shrink();
                    }

                    return const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Informe uma altura valida para continuar.',
                        style: TextStyle(
                          color: AppThemeColors.errorText,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(height: AppSpacing.xs),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppThemeColors.textSecondary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Essa informacao ajuda a sugerir matches mais compativeis.',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
