import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'option_card/index.dart';

class MatchOptionDialogView extends StatelessWidget {
  final String matchName;
  final VoidCallback onViewProfile;
  final Future<void> Function() onSendMessage;
  final VoidCallback onCancel;

  const MatchOptionDialogView({
    required this.matchName,
    required this.onViewProfile,
    required this.onSendMessage,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppThemeColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Opções para $matchName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppThemeColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            OptionCard(
              label: 'Ver perfil',
              icon: Icons.remove_red_eye_outlined,
              onTap: onViewProfile,
            ),
            const SizedBox(height: 8),
            OptionCard(
              label: 'Mandar mensagem',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => onSendMessage(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: AppThemeColors.textSecondary,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
