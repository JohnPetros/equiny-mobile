import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedScreenView extends StatelessWidget {
  const FeedScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Feed'),
      ),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Placeholder: Feed',
            style: TextStyle(color: AppThemeColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
