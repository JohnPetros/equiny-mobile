import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/feed_readiness_checklist_done_tile/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/feed_readiness_checklist_pending_tile/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileHorseFeedReadinessSectionView extends StatelessWidget {
  final List<String> feedReadinessChecklist;

  const ProfileHorseFeedReadinessSectionView({
    required this.feedReadinessChecklist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReady = feedReadinessChecklist.isEmpty;
    final bool hasImagePending = feedReadinessChecklist.any(
      (String item) => item.toLowerCase().contains('foto'),
    );
    final double progressValue = isReady ? 1 : 0.85;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF14151E), Color(0xFF12131A)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF2A2A38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ReadinessRing(progressValue: progressValue),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    const Text(
                      'Pronto para o Feed',
                      style: TextStyle(
                        color: AppThemeColors.textMain,
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isReady
                          ? 'Seu perfil esta completo e pronto para aparecer no feed.'
                          : 'Complete as etapas finais para maxima visibilidade do seu anuncio.',
                      style: const TextStyle(
                        color: AppThemeColors.textSecondary,
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1118),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFF1E1F2A)),
            ),
            child: Column(
              children: <Widget>[
                FeedReadinessChecklistDoneTile(
                  text: 'Fotos da Galeria (Min 1)',
                  done: !hasImagePending,
                ),
                const SizedBox(height: AppSpacing.sm),
                const FeedReadinessChecklistDoneTile(
                  text: 'Dados Obrigatorios',
                  done: true,
                ),
                if (!isReady) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  ...feedReadinessChecklist.map((String item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FeedReadinessChecklistPendingTile(
                        text: _mapPendingLabel(item),
                        highlighted: item.toLowerCase().contains('localizacao'),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _mapPendingLabel(String item) {
  final String lower = item.toLowerCase();

  if (lower.contains('localizacao')) {
    return 'Localizacao Pendente';
  }

  if (lower.contains('foto')) {
    return 'Fotos Pendentes';
  }

  return item;
}

class _ReadinessRing extends StatelessWidget {
  final double progressValue;

  const _ReadinessRing({required this.progressValue});

  @override
  Widget build(BuildContext context) {
    final int percent = (progressValue * 100).round();

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progressValue,
              strokeWidth: 6,
              backgroundColor: const Color(0xFF2A2A36),
              color: AppThemeColors.primary,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: AppThemeColors.textMain,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
