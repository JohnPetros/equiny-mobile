import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_content/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_state/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class InboxScreenView extends ConsumerWidget {
  const InboxScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InboxScreenPresenter presenter = ref.watch(
      inboxScreenPresenterProvider,
    );

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: Watch((BuildContext context) {
          if (presenter.isLoadingInitial.value) {
            return const InboxScreenLoadingState();
          }

          if (presenter.hasError.value) {
            return InboxScreenErrorState(
              message:
                  presenter.errorMessage.value ?? 'Erro ao carregar conversas.',
              onRetry: presenter.retry,
            );
          }

          if (presenter.isEmptyState.value) {
            return InboxScreenEmptyState(onGoToMatches: presenter.goToMatches);
          }

          return InboxScreenContent(
            presenter: presenter,
            onTapItem: (ChatDto item) {
              presenter.openChat(item);
            },
          );
        }),
      ),
    );
  }
}
