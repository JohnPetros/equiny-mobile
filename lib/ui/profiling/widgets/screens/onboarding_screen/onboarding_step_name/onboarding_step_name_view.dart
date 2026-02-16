import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class OnboardingStepNameView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;

  const OnboardingStepNameView({
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
              'Qual e o nome do seu cavalo?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Vamos comecar pelo basico.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Nome do cavalo',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ReactiveTextField<String>(
              formControlName: 'name',
              style: const TextStyle(
                color: AppThemeColors.textMain,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                hintText: 'Ex.: Diamante',
                suffixIcon: Icon(Icons.edit, color: AppThemeColors.primary),
              ),
              validationMessages: _messages,
              showErrors: (AbstractControl<Object> control) {
                return control.invalid && (control.touched || submitAttempted);
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
                    'Voce pode mudar isso depois no perfil do cavalo.',
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

Map<String, String Function(Object)> get _messages {
  return <String, String Function(Object)>{
    ValidationMessage.required: (_) => 'Campo obrigatorio.',
    ValidationMessage.minLength: (_) => 'Nome muito curto.',
    ValidationMessage.maxLength: (_) => 'Nome muito longo.',
  };
}
