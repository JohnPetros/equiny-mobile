import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/inbox_chat_list_item_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxChatListItemView extends ConsumerWidget {
  final ChatDto chat;
  final VoidCallback onTap;

  const InboxChatListItemView({
    required this.chat,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InboxChatListItemPresenter itemPresenter = ref.watch(
      inboxChatListItemPresenterProvider,
    );
    final InboxScreenPresenter screenPresenter = ref.watch(
      inboxScreenPresenterProvider,
    );
    final FileStorageDriver fileStorageDriver = ref.watch(
      fileStorageDriverProvider,
    );
    final CacheDriver cacheDriver = ref.watch(cacheDriverProvider);
    final String ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';

    final bool isLastMessageFromOwner = chat.lastMessage.senderId == ownerId;
    final String recipientName = chat.recipient.name?.trim().isNotEmpty == true
        ? chat.recipient.name!.trim()
        : 'Sem nome';
    final String avatarUrl = chat.recipient.avatar?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(chat.recipient.avatar?.key ?? '');
    final String initials = screenPresenter.buildRecipientInitials(
      recipientName,
    );
    final String formattedTimestamp = screenPresenter.formatRelativeTimestamp(
      chat.lastMessage.sentAt,
    );
    final bool showUnreadBadge = itemPresenter.shouldShowUnreadBadge(
      chat.unreadCount,
    );
    final String preview = itemPresenter.truncatePreview(
      chat.lastMessage.content,
    );

    final bool hasUnread = showUnreadBadge;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 2,
          color: Color.fromARGB(13, 255, 255, 255),
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppThemeColors.backgroundAlt,
                  backgroundImage: avatarUrl.isEmpty
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                recipientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: AppFontSize.md,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              formattedTimestamp,
                              style: TextStyle(
                                color: hasUnread
                                    ? AppThemeColors.primary
                                    : AppThemeColors.textSecondary,
                                fontSize: AppFontSize.xs,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            if (isLastMessageFromOwner)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  chat.lastMessage.isReadByRecipient
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 16,
                                  color: AppThemeColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasUnread
                                      ? AppThemeColors.textMain
                                      : AppThemeColors.textSecondary,
                                  fontSize: AppFontSize.sm,
                                  fontWeight: hasUnread
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (showUnreadBadge)
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 20,
                                  minWidth: 20,
                                ),
                                margin: const EdgeInsets.only(left: 8),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppThemeColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  chat.unreadCount > 99
                                      ? '99+'
                                      : chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: AppFontSize.xxs,
                                    color: AppThemeColors.background,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 2,
          color: Color.fromARGB(13, 255, 255, 255),
        ),
      ],
    );
  }
}
