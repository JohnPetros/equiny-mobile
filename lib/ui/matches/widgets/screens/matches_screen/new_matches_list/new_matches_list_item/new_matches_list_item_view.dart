import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/new_matches_list/new_matches_list_item/new_matches_list_item_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewMatchesListItemView extends ConsumerWidget {
  final HorseMatchDto item;
  final VoidCallback onTap;

  const NewMatchesListItemView({
    required this.item,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FileStorageDriver fileStorageDriver = ref.read(
      fileStorageDriverProvider,
    );
    final NewMatchesListItemPresenter presenter = ref.read(
      newMatchesListItemPresenterProvider,
    );

    final String horseImageUrl =
        item.ownerHorseImage?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(item.ownerHorseImage?.key ?? '');

    final String ownerAvatarUrl = item.ownerAvatar?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getFileUrl(item.ownerAvatar?.key ?? '');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // Horse image (large circle)
                  CircleAvatar(
                    radius: 34,
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
                  // Owner avatar (small circle, bottom-left overlapping)
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
                        radius: 14,
                        backgroundColor: AppThemeColors.backgroundAlt,
                        backgroundImage: ownerAvatarUrl.isEmpty
                            ? null
                            : NetworkImage(ownerAvatarUrl),
                        child: ownerAvatarUrl.isEmpty
                            ? Text(
                                presenter.buildOwnerInitials(item.ownerName),
                                style: const TextStyle(
                                  fontSize: 10,
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
            const SizedBox(height: 10),
            Text(
              item.ownerHorseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
