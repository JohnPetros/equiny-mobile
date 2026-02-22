import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'option_card/index.dart';

class MatchOptionDialogView extends StatelessWidget {
  final String matchName;
  final String? ownerAvatarUrl;
  final VoidCallback onViewProfile;
  final Future<void> Function() onSendMessage;
  final VoidCallback onCancel;

  const MatchOptionDialogView({
    required this.matchName,
    required this.onViewProfile,
    required this.onSendMessage,
    required this.onCancel,
    this.ownerAvatarUrl,
    super.key,
  });

  String _buildInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(' ')
        .where((String part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar =
        ownerAvatarUrl != null && ownerAvatarUrl!.trim().isNotEmpty;

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
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppThemeColors.backgroundAlt,
                backgroundImage: hasAvatar
                    ? NetworkImage(ownerAvatarUrl!)
                    : null,
                child: hasAvatar
                    ? null
                    : Text(
                        _buildInitials(matchName),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.textMain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
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
