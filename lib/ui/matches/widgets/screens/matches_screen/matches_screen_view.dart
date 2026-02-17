import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MatchesScreenView extends StatelessWidget {
  const MatchesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Matches'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Placeholder: Matches',
            style: TextStyle(color: AppThemeColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
