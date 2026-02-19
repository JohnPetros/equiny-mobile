import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_horse_details_screen/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_screen/feed_filters_sheet/feed_filters_sheet_view.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_screen/feed_horse_card/index.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_screen/feed_screen_presenter.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_screen/feed_screen_state/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FeedScreenView extends ConsumerWidget {
  const FeedScreenView({super.key});

  void _openFilters(BuildContext context, FeedScreenPresenter presenter) {
    final HorseFeedFiltersDto? currentFilters = presenter.filters.value;
    if (currentFilters == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FeedFiltersSheetView(
          initialFilters: currentFilters,
          onApply: presenter.applyFilters,
          onClear: presenter.clearFilters,
        );
      },
    );
  }

  void _openHorseDetailsSheet({
    required BuildContext context,
    required FeedHorseDto horse,
    required FileStorageDriver fileStorageDriver,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.96,
          child: FeedHorseDetailsScreen(
            horse: horse,
            fileStorageDriver: fileStorageDriver,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(feedScreenPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.md,
        toolbarHeight: 72,
        leading: IconButton(
          onPressed: () => _openFilters(context, presenter),
          icon: const Icon(Icons.tune_rounded),
          color: Colors.white.withValues(alpha: 0.9),
        ),
        title: const Text(
          'FEED',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Watch((BuildContext context) {
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => _openFilters(context, presenter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppThemeColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Filtros',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        child: Text(
                          '${presenter.activeFiltersCount.value}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
          child: Watch((BuildContext context) {
            if (presenter.isLoadingInitial.value) {
              return const FeedScreenLoadingState();
            }

            if (presenter.isBlocked.value) {
              return FeedScreenBlockedState(
                message:
                    presenter.blockedMessage.value ??
                    'Complete o perfil do cavalo para liberar o feed.',
                onGoToProfile: presenter.goToProfile,
              );
            }

            if (presenter.errorMessage.value != null) {
              return FeedScreenErrorState(
                message: presenter.errorMessage.value!,
                onRetry: presenter.retry,
              );
            }

            if (presenter.cards.value.isEmpty) {
              return FeedScreenEmptyState(
                onClearFilters: presenter.clearFilters,
              );
            }

            final currentCard = presenter.currentCard.value;
            if (currentCard == null) {
              return const FeedScreenEndState();
            }

            final fileStorageDriver = ref.read(fileStorageDriverProvider);

            return Column(
              children: <Widget>[
                Expanded(
                  child: FeedHorseCard(
                    key: ValueKey<String>(currentCard.id),
                    horse: currentCard,
                    fileStorageDriver: fileStorageDriver,
                    onLike: presenter.likeCurrentHorse,
                    onDislike: presenter.dislikeCurrentHorse,
                    onDetails: () {
                      _openHorseDetailsSheet(
                        context: context,
                        horse: currentCard,
                        fileStorageDriver: fileStorageDriver,
                      );
                    },
                  ),
                ),
                if (presenter.isLoadingMore.value)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
