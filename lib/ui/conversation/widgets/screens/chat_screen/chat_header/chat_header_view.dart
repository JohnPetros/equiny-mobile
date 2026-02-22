import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHeaderView extends ConsumerWidget {
  final RecipientDto recipient;
  final VoidCallback onBack;
  final VoidCallback onOpenProfile;

  const ChatHeaderView({
    required this.recipient,
    required this.onBack,
    required this.onOpenProfile,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChatHeaderPresenter presenter = ref.watch(
      chatHeaderPresenterProvider,
    );
    final String avatarUrl = presenter.resolveAvatarUrl(recipient);
    final bool isOnline = presenter.isOnline(recipient);
    final String presenceLabel = presenter.resolvePresenceLabel(recipient);

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
          Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: AppThemeColors.inputBackground,
                backgroundImage: avatarUrl.isEmpty
                    ? null
                    : NetworkImage(avatarUrl),
                child: avatarUrl.isEmpty
                    ? const Icon(
                        Icons.pets,
                        size: 18,
                        color: AppThemeColors.textSecondary,
                      )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppThemeColors.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  recipient.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppThemeColors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  presenceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isOnline
                        ? Colors.green
                        : AppThemeColors.textSecondary,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            onPressed: onOpenProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemeColors.primary,
              side: const BorderSide(color: AppThemeColors.primary),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xxs,
              ),
              textStyle: const TextStyle(
                fontSize: AppFontSize.xs,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver perfil'),
          ),
        ],
      ),
    );
  }
}
