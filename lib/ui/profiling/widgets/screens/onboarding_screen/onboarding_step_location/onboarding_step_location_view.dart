import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class OnboardingStepLocationView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;

  const OnboardingStepLocationView({
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
              'Onde ele esta localizado?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Informe a cidade e o estado.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ReactiveTextField<String>(
              formControlName: 'city',
              style: const TextStyle(color: AppThemeColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Cidade',
                suffixIcon: Icon(
                  Icons.location_city,
                  color: AppThemeColors.primary,
                ),
              ),
              validationMessages: _messages,
              showErrors: _showErrors,
            ),
            const SizedBox(height: AppSpacing.sm),
            ReactiveTextField<String>(
              formControlName: 'state',
              style: const TextStyle(color: AppThemeColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Estado',
                suffixIcon: Icon(Icons.map, color: AppThemeColors.primary),
              ),
              textCapitalization: TextCapitalization.characters,
              validationMessages: _messages,
              showErrors: _showErrors,
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
                    'Isso ajuda a personalizar sua experiencia e encontrar compradores proximos.',
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
    ValidationMessage.minLength: (_) => 'Valor muito curto.',
    ValidationMessage.maxLength: (_) => 'Valor muito longo.',
  };
}
