import 'dart:async';

import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/global/widgets/lottie/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/feed_horse_details_screen/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/feed_screen/feed_filters_sheet/feed_filters_sheet_view.dart';
import 'package:equiny/ui/profiling/widgets/screens/feed_screen/feed_horse_card/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/feed_screen/feed_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/feed_screen/feed_screen_state/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum _SwipeFeedbackType { like, dislike }

class FeedScreenView extends ConsumerStatefulWidget {
  const FeedScreenView({super.key});

  @override
  ConsumerState<FeedScreenView> createState() => _FeedScreenViewState();
}

class _FeedScreenViewState extends ConsumerState<FeedScreenView> {
  _SwipeFeedbackType? _swipeFeedbackType;
  int _swipeFeedbackKey = 0;
  Timer? _swipeFeedbackTimer;
  Timer? _pendingLikeTimer;

  @override
  void dispose() {
    _swipeFeedbackTimer?.cancel();
    _pendingLikeTimer?.cancel();
    super.dispose();
  }

  void _showSwipeFeedback(_SwipeFeedbackType type) {
    _swipeFeedbackTimer?.cancel();
    setState(() {
      _swipeFeedbackType = type;
      _swipeFeedbackKey += 1;
    });

    _swipeFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _swipeFeedbackType = null;
      });
    });
  }

  void _handleLike(FeedScreenPresenter presenter) {
    _showSwipeFeedback(_SwipeFeedbackType.like);
    _pendingLikeTimer?.cancel();
    _pendingLikeTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) {
        return;
      }

      unawaited(presenter.likeCurrentHorse());
    });
  }

  void _handleDislike(FeedScreenPresenter presenter) {
    _pendingLikeTimer?.cancel();
    _showSwipeFeedback(_SwipeFeedbackType.dislike);
    presenter.dislikeCurrentHorse();
  }

  String _feedbackAssetPath(_SwipeFeedbackType type) {
    return switch (type) {
      _SwipeFeedbackType.like => 'assets/lotties/like.lottie',
      _SwipeFeedbackType.dislike => 'assets/lotties/dislike.lottie',
    };
  }

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
  Widget build(BuildContext context) {
    final presenter = ref.watch(feedScreenPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: AppSpacing.md,
        toolbarHeight: 72,
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

            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      child: FeedHorseCard(
                        key: ValueKey<String>(currentCard.id),
                        horse: currentCard,
                        fileStorageDriver: fileStorageDriver,
                        onLike: () => _handleLike(presenter),
                        onDislike: () => _handleDislike(presenter),
                        onDetails: () {
                          _openHorseDetailsSheet(
                            context: context,
                            horse: currentCard,
                            fileStorageDriver: fileStorageDriver,
                          );
                        },
                        currentHorseLocation:
                            presenter.currentHorseLocation.value,
                      ),
                    ),
                    if (presenter.isLoadingMore.value)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
                if (_swipeFeedbackType != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Lottie(
                            assetPath: _feedbackAssetPath(_swipeFeedbackType!),
                            key: ValueKey<String>(
                              '${_swipeFeedbackType!.name}-$_swipeFeedbackKey',
                            ),
                            repeat: false,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
