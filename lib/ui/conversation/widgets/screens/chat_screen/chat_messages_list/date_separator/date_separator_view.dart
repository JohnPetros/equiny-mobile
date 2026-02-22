import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/date_separator_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DateSeparatorView extends StatelessWidget {
  final String label;

  const DateSeparatorView({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = DateSeparatorPresenter();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppThemeColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Text(
            presenter.formatLabel(label),
            style: const TextStyle(
              color: AppThemeColors.textSecondary,
              fontSize: AppFontSize.xs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
