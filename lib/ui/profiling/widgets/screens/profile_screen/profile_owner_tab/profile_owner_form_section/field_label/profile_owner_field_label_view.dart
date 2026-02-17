import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileOwnerFieldLabelView extends StatelessWidget {
  final String text;

  const ProfileOwnerFieldLabelView({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppThemeColors.textMain,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
