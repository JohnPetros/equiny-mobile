import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatEmptyStateView extends StatelessWidget {
  final Future<void> Function(String text) onSuggestionTap;

  const ChatEmptyStateView({required this.onSuggestionTap, super.key});

  @override
  Widget build(BuildContext context) {
    const suggestions = <String>[
      'Oi! Tudo bem com seu cavalo?',
      'Podemos falar sobre localizacao?',
      'Tem disponibilidade esta semana?',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.chat_bubble_outline,
              color: AppThemeColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Inicie a conversa',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Envie a primeira mensagem ou use uma sugestao.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppThemeColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: suggestions.map((String text) {
                return ActionChip(
                  label: Text(text),
                  onPressed: () => onSuggestionTap(text),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
