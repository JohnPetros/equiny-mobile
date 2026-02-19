import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_header/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_list/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_screen_state/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/new_matches_list/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MatchesScreenContentView extends StatelessWidget {
  final MatchesScreenPresenter presenter;
  final void Function(HorseMatchDto item) onTapItem;
  final Future<bool> Function(HorseMatchDto item)? onDeleteItem;

  const MatchesScreenContentView({
    required this.presenter,
    required this.onTapItem,
    this.onDeleteItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((BuildContext context) {
      if (presenter.isLoadingInitial.value) {
        return const MatchesScreenLoadingState();
      }

      if (presenter.hasError.value) {
        return MatchesScreenErrorState(
          message: presenter.errorMessage.value ?? 'Erro ao carregar matches.',
          onRetry: presenter.retry,
        );
      }

      if (presenter.isEmptyState.value) {
        return MatchesScreenEmptyState(onGoToFeed: presenter.goToFeed);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  MatchesHeader(
                    title: 'Matches',
                    newCount: presenter.newCount.value,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (presenter.newMatches.value.isNotEmpty)
                    NewMatchesList(
                      items: presenter.newMatches.value,
                      onTapItem: onTapItem,
                    ),
                ],
              ),
            ),

            if (presenter.newMatches.value.isNotEmpty)
              const SizedBox(height: AppSpacing.lg),
            MatchesList(
              items: presenter.seenMatches.value,
              onTapItem: onTapItem,
              onDeleteItem: onDeleteItem,
            ),
          ],
        ),
      );
    });
  }
}
