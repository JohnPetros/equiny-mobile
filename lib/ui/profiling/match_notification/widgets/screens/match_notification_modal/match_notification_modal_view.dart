import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/profiling/match_notification/widgets/screens/match_notification_modal/confetti_overlay/index.dart';
import 'package:equiny/ui/profiling/match_notification/widgets/screens/match_notification_modal/match_horse_avatar/index.dart';
import 'package:equiny/ui/profiling/match_notification/widgets/screens/match_notification_modal/match_notification_modal_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MatchNotificationModalView extends ConsumerWidget {
  const MatchNotificationModalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(matchNotificationModalPresenterProvider);

    return Watch((BuildContext context) {
      final HorseMatchDto? match = presenter.currentMatch.value;

      if (match == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return const SizedBox.shrink();
      }

      final bool isLoading = presenter.isCreatingChat.value;
      final String? chatError = presenter.chatError.value;

      return Scaffold(
        backgroundColor: AppThemeColors.background,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 240) {
              final bool shouldClose = presenter.handleClose();
              if (shouldClose && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                const ConfettiOverlay(),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      right: AppSpacing.md,
                    ),
                    child: IconButton(
                      onPressed: () {
                        final bool shouldClose = presenter.handleClose();
                        if (shouldClose && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppThemeColors.textMain,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: Column(
                          key: ValueKey<String>(
                            '${match.ownerId}-${match.ownerHorseId}-${match.createdAt.toIso8601String()}',
                          ),
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              'Deu match!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppThemeColors.textMain,
                                fontSize: AppFontSize.xxxxl,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Você e ${match.ownerHorseName} curtiram um ao outro.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppThemeColors.textSecondary,
                                fontSize: AppFontSize.md,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 64),
                            MatchHorseAvatar(
                              imageUrl: presenter.horseImageUrl.value,
                              size: 240,
                            ),
                            const SizedBox(height: 64),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final bool didOpenChat = await presenter
                                            .handleGoToChat();
                                        if (!context.mounted) {
                                          return;
                                        }
                                        if (didOpenChat &&
                                            Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.chat_bubble_outline),
                                label: Text(
                                  isLoading
                                      ? 'Abrindo chat...'
                                      : 'Ir para o chat',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  final bool shouldClose = presenter
                                      .handleContinue();
                                  if (shouldClose &&
                                      Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                  side: const BorderSide(
                                    color: AppThemeColors.border,
                                  ),
                                ),
                                child: const Text('Continuar deslizando'),
                              ),
                            ),
                            if ((chatError ?? '').isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                chatError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppThemeColors.errorText,
                                  fontSize: AppFontSize.sm,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 220.ms, curve: Curves.easeOut);
    });
  }
}
