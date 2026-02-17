import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ConversationsScreenView extends StatelessWidget {
  const ConversationsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Conversations'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Placeholder: Conversations',
            style: TextStyle(color: AppThemeColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
