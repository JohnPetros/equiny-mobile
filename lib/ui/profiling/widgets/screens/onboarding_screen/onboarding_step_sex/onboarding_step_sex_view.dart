import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class OnboardingStepSexView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;
  final List<String> sexOptions;

  const OnboardingStepSexView({
    required this.form,
    required this.submitAttempted,
    required this.sexOptions,
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
              'Qual e o sexo dele?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Selecione uma opcao abaixo para personalizarmos a experiencia.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ReactiveValueListenableBuilder<String>(
              formControlName: 'sex',
              builder:
                  (
                    BuildContext context,
                    AbstractControl<String> control,
                    Widget? child,
                  ) {
                    final String selectedSex = control.value ?? '';

                    return Column(
                      children: sexOptions.map((String sex) {
                        final bool isSelected = selectedSex == sex;
                        final bool isMale = sex.toLowerCase() == 'macho';

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppThemeColors.backgroundAlt,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected
                                  ? AppThemeColors.primary
                                  : AppThemeColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            onTap: () {
                              form.control('sex').value = sex;
                              form.control('sex').markAsTouched();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isMale ? Icons.male : Icons.female,
                                      color: AppThemeColors.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          sex,
                                          style: const TextStyle(
                                            color: AppThemeColors.textMain,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isMale
                                              ? 'Cavalo / Potro'
                                              : 'Egua / Potra',
                                          style: const TextStyle(
                                            color: AppThemeColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? AppThemeColors.primary
                                        : AppThemeColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
            ),
            ReactiveFormConsumer(
              builder:
                  (BuildContext context, FormGroup formGroup, Widget? child) {
                    final bool hasError =
                        form.control('sex').invalid &&
                        (form.control('sex').touched || submitAttempted);

                    if (!hasError) {
                      return const SizedBox.shrink();
                    }

                    return const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Selecione o sexo para continuar.',
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
                    'Essa informacao ajuda a encontrar parceiros compativeis.',
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
