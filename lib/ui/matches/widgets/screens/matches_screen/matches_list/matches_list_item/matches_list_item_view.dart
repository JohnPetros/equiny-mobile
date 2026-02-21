import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_list/matches_list_item/matches_list_item_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesListItemView extends ConsumerWidget {
  final HorseMatchDto item;
  final VoidCallback onTap;
  final Future<bool> Function(HorseMatchDto item)? onDelete;

  const MatchesListItemView({
    required this.item,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MatchesListItemPresenter presenter = ref.watch(
      matchesListItemPresenterProvider,
    );
    final FileStorageDriver fileStorageDriver = ref.read(
      fileStorageDriverProvider,
    );
    final String avatarUrl = item.ownerAvatar?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(item.ownerAvatar?.key ?? '');

    Widget itemContent = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeColors.border),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppThemeColors.backgroundAlt,
              backgroundImage: avatarUrl.isEmpty
                  ? null
                  : NetworkImage(avatarUrl),
              child: avatarUrl.isEmpty
                  ? Text(
                      presenter.buildOwnerInitials(item.ownerName),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    presenter.formatRelativeTime(item.createdAt),
                    style: const TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onDelete == null) {
      return itemContent;
    }

    return Dismissible(
      key: ValueKey<String>(item.ownerHorseId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Desfazer match',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Desfazer match'),
              content: Text('Deseja desfazer o match com ${item.ownerName}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Desfazer match'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return false;
        }

        return await onDelete!(item);
      },
      child: itemContent,
    );
  }
}
