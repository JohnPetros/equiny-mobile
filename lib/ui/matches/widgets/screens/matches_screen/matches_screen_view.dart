import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/match_option_dialog/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_screen_content_view.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesScreenView extends ConsumerWidget {
  const MatchesScreenView({super.key});

  Future<void> _openMatchOptionsDialog(
    BuildContext context,
    MatchesScreenPresenter presenter,
  ) {
    final HorseMatchDto? selectedMatch = presenter.selectedMatch.value;
    if (selectedMatch == null) {
      return Future<void>.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppThemeColors.backgroundAlt,
      builder: (BuildContext context) {
        return MatchOptionDialog(
          matchName: selectedMatch.ownerName,
          onViewProfile: () {
            Navigator.of(context).pop();
            presenter.handleTapViewProfile();
          },
          onSendMessage: () async {
            Navigator.of(context).pop();
            await presenter.handleTapSendMessage();
          },
          onCancel: () {
            Navigator.of(context).pop();
            presenter.closeMatchOptions();
          },
        );
      },
    ).whenComplete(presenter.closeMatchOptions);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(matchesScreenPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: MatchesScreenContentView(
          presenter: presenter,
          onTapItem: (HorseMatchDto item) {
            presenter.openMatchOptions(item);
            _openMatchOptionsDialog(context, presenter);
          },
          onDeleteItem: presenter.handleDeleteMatch,
        ),
      ),
    );
  }
}
