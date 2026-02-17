import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/sign_in_form/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_footer/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_header/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignInScreenView extends ConsumerWidget {
  const SignInScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(signInScreenPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Watch((BuildContext context) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppThemeColors.border),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x80000000),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SignUpHeader(
                        title: 'Entrar',
                        subtitle: 'Acesse sua conta para continuar.',
                        iconData: Icons.login,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      if (presenter.generalError.value != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppThemeColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: AppThemeColors.error.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Text(
                            presenter.generalError.value!,
                            style: const TextStyle(
                              color: AppThemeColors.errorText,
                            ),
                          ),
                        ),
                      SignInForm(
                        form: presenter.form.value,
                        submitAttempted: presenter.submitAttempted.value,
                        isPasswordVisible: presenter.isPasswordVisible.value,
                        onTogglePasswordVisibility:
                            presenter.togglePasswordVisibility,
                        onSubmit: presenter.submit,
                        isLoading: presenter.isLoading.value,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SignUpFooter(
                        promptText: 'Não tem uma conta? ',
                        actionText: 'Criar conta',
                        onTapAction: presenter.goToSignUp,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
