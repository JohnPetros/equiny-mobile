import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreenView extends StatelessWidget {
  final String chatId;

  const ChatScreenView({required this.chatId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(Routes.inbox);
          },
        ),
      ),
      body: Center(
        child: Text(
          'Thread $chatId',
          style: const TextStyle(color: AppThemeColors.textSecondary),
        ),
      ),
    );
  }
}
