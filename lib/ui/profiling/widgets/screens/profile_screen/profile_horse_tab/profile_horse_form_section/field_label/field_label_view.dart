import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FieldLabelView extends StatelessWidget {
  final String text;

  const FieldLabelView(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppThemeColors.textMain,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
