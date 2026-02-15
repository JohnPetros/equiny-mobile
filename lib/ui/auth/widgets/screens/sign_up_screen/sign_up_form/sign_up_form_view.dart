import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignUpFormView extends StatelessWidget {
  final FormGroup form;
  final bool submitAttempted;
  final bool isPasswordVisible;
  final bool isPasswordConfirmationVisible;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onTogglePasswordConfirmationVisibility;
  final VoidCallback onSubmit;
  final bool isLoading;

  const SignUpFormView({
    required this.form,
    required this.submitAttempted,
    required this.isPasswordVisible,
    required this.isPasswordConfirmationVisible,
    required this.onTogglePasswordVisibility,
    required this.onTogglePasswordConfirmationVisibility,
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    InputDecoration buildDecoration({
      required String hint,
      required String label,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppThemeColors.inputBackground,
        labelStyle: const TextStyle(
          color: AppThemeColors.textMain,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppThemeColors.textSecondary,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppThemeColors.error),
        ),
      );
    }

    return ReactiveForm(
      formGroup: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ReactiveTextField<String>(
            formControlName: 'name',
            style: const TextStyle(color: AppThemeColors.textMain),
            cursorColor: AppThemeColors.primary,
            decoration: buildDecoration(
              label: 'Nome do dono',
              hint: 'Seu nome',
            ),
            validationMessages: _validationMessages,
            showErrors: _showErrors,
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'email',
            style: const TextStyle(color: AppThemeColors.textMain),
            cursorColor: AppThemeColors.primary,
            decoration: buildDecoration(
              label: 'E-mail',
              hint: 'voce@email.com',
            ),
            validationMessages: _validationMessages,
            showErrors: _showErrors,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'password',
            style: const TextStyle(color: AppThemeColors.textMain),
            cursorColor: AppThemeColors.primary,
            decoration: buildDecoration(
              label: 'Senha',
              hint: '••••••••',
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ),
            obscureText: !isPasswordVisible,
            validationMessages: _validationMessages,
            showErrors: _showErrors,
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'passwordConfirmation',
            style: const TextStyle(color: AppThemeColors.textMain),
            cursorColor: AppThemeColors.primary,
            decoration: buildDecoration(
              label: 'Confirmar senha',
              hint: '••••••••',
              suffixIcon: IconButton(
                onPressed: onTogglePasswordConfirmationVisibility,
                icon: Icon(
                  isPasswordConfirmationVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppThemeColors.textSecondary,
                ),
              ),
            ),
            obscureText: !isPasswordConfirmationVisible,
            validationMessages: _validationMessages,
            showErrors: _showErrors,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Criar conta'),
          ),
        ],
      ),
    );
  }
}

bool _showErrors(AbstractControl<Object> control) {
  return control.invalid && (control.touched || control.dirty);
}

Map<String, String Function(Object)> get _validationMessages {
  return <String, String Function(Object)>{
    ValidationMessage.required: (_) => 'Campo obrigatorio.',
    ValidationMessage.email: (_) => 'Informe um e-mail valido.',
    ValidationMessage.minLength: (_) => 'Valor abaixo do minimo permitido.',
    ValidationMessage.maxLength: (_) => 'Valor acima do maximo permitido.',
    ValidationMessage.mustMatch: (_) => 'As senhas precisam ser iguais.',
    'server': (Object error) => error.toString(),
  };
}
