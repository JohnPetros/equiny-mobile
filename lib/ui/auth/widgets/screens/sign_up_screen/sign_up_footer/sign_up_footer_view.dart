import 'package:flutter/material.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';

class SignUpFooterView extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTapAction;

  const SignUpFooterView({
    required this.promptText,
    required this.actionText,
    required this.onTapAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            promptText,
            style: const TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: onTapAction,
            child: Text(
              actionText,
              style: const TextStyle(
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
