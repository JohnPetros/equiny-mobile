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
    final String horseImageUrl =
        item.ownerHorseImage?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(item.ownerHorseImage?.key ?? '');

    final String ownerAvatarUrl = item.ownerAvatar?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(item.ownerAvatar?.key ?? '');

    final String locationText =
        '${item.ownerLocation.city}, ${item.ownerLocation.state}';

    Widget itemContent = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppThemeColors.surface,
                    backgroundImage: horseImageUrl.isEmpty
                        ? null
                        : NetworkImage(horseImageUrl),
                    child: horseImageUrl.isEmpty
                        ? Text(
                            presenter.buildOwnerInitials(item.ownerHorseName),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -4,
                    left: -4,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppThemeColors.background,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppThemeColors.backgroundAlt,
                        backgroundImage: ownerAvatarUrl.isEmpty
                            ? null
                            : NetworkImage(ownerAvatarUrl),
                        child: ownerAvatarUrl.isEmpty
                            ? Text(
                                presenter.buildOwnerInitials(item.ownerName),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.ownerHorseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppThemeColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Text(
                        item.ownerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppThemeColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppThemeColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
