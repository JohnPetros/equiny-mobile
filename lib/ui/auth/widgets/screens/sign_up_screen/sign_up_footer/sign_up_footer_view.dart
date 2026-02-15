import 'package:flutter/material.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignUpFooterView extends StatelessWidget {
  final VoidCallback onTapSignIn;

  const SignUpFooterView({required this.onTapSignIn, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          const Text(
            'Ja tem uma conta? ',
            style: TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: onTapSignIn,
            child: const Text(
              'Entrar',
              style: TextStyle(
                color: AppThemeColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
