import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class OnboardingStepBreedView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;
  final List<String> breedOptions;

  const OnboardingStepBreedView({
    required this.form,
    required this.submitAttempted,
    required this.breedOptions,
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
              'Qual e a raca dele?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Selecione uma opcao para personalizar os matches.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ReactiveValueListenableBuilder<String>(
              formControlName: 'breed',
              builder:
                  (
                    BuildContext context,
                    AbstractControl<String> control,
                    Widget? child,
                  ) {
                    final String selectedBreed = control.value ?? '';

                    return Column(
                      children: breedOptions.map((String breed) {
                        final bool isSelected = selectedBreed == breed;

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
                              form.control('breed').value = breed;
                              form.control('breed').markAsTouched();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: AppThemeColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.pets,
                                      color: AppThemeColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      breed,
                                      style: const TextStyle(
                                        color: AppThemeColors.textMain,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                        form.control('breed').invalid &&
                        (form.control('breed').touched || submitAttempted);

                    if (!hasError) {
                      return const SizedBox.shrink();
                    }

                    return const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Selecione uma raca para continuar.',
                        style: TextStyle(
                          color: AppThemeColors.errorText,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
