import 'package:flutter/material.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignUpVerificationNoticeView extends StatelessWidget {
  final String email;
  final VoidCallback onTapGoToSignIn;
  final bool isLoading;

  const SignUpVerificationNoticeView({
    required this.email,
    required this.onTapGoToSignIn,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppThemeColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppThemeColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: const Text(
            'Enviamos um e-mail de verificacao para o endereco informado. Confirme seu e-mail antes de fazer login.',
            style: TextStyle(
              color: AppThemeColors.textMain,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppThemeColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: isLoading ? null : onTapGoToSignIn,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ir para login'),
        ),
      ],
    );
  }
}
