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
    final String avatarUrl = item.ownerAvatar?.key.trim().isEmpty ?? true
        ? ''
        : fileStorageDriver.getImageUrl(item.ownerAvatar?.key ?? '');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: AppThemeColors.surface,
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
            const SizedBox(height: 8),
            Text(
              item.ownerName,
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
