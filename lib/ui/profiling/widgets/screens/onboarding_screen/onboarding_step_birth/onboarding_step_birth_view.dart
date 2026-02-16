import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class OnboardingStepBirthView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;
  final List<int> availableMonths;
  final List<int> availableYears;

  const OnboardingStepBirthView({
    required this.form,
    required this.submitAttempted,
    required this.availableMonths,
    required this.availableYears,
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
              'Quando ele nasceu?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Selecione mes e ano de nascimento.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: ReactiveDropdownField<int>(
                    formControlName: 'birthMonth',
                    style: const TextStyle(color: AppThemeColors.textMain),
                    dropdownColor: AppThemeColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Mes',
                      hintText: 'Selecione',
                    ),
                    items: availableMonths
                        .map(
                          (int month) => DropdownMenuItem<int>(
                            value: month,
                            child: Text(month.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    validationMessages: _messages,
                    showErrors: _showErrors,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ReactiveDropdownField<int>(
                    formControlName: 'birthYear',
                    style: const TextStyle(color: AppThemeColors.textMain),
                    dropdownColor: AppThemeColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      hintText: 'Selecione',
                    ),
                    items: availableYears
                        .map(
                          (int year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                    validationMessages: _messages,
                    showErrors: _showErrors,
                  ),
                ),
              ],
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
                    'Se nao souber a data exata, use uma aproximacao.',
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

  bool _showErrors(AbstractControl<Object> control) {
    return control.invalid && (control.touched || submitAttempted);
  }
}

Map<String, String Function(Object)> get _messages {
  return <String, String Function(Object)>{
    ValidationMessage.required: (_) => 'Campo obrigatorio.',
    ValidationMessage.min: (_) => 'Ano invalido.',
    ValidationMessage.max: (_) => 'Ano invalido.',
  };
}
