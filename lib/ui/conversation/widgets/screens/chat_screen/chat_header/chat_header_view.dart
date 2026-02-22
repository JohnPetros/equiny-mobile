import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatHeaderView extends StatelessWidget {
  final String recipientName;
  final String recipientAvatarUrl;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onOpenProfile;

  const ChatHeaderView({
    required this.recipientName,
    required this.recipientAvatarUrl,
    required this.subtitle,
    required this.onBack,
    required this.onOpenProfile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppThemeColors.border)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppThemeColors.textMain),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppThemeColors.inputBackground,
            backgroundImage: recipientAvatarUrl.isEmpty
                ? null
                : NetworkImage(recipientAvatarUrl),
            child: recipientAvatarUrl.isEmpty
                ? const Icon(Icons.pets, size: 16, color: AppThemeColors.textSecondary)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  recipientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeColors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeColors.textSecondary,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(onPressed: onOpenProfile, child: const Text('Ver perfil')),
        ],
      ),
    );
  }
}
