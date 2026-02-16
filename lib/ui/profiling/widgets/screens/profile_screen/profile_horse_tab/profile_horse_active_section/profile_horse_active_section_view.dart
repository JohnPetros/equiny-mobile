import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileHorseActiveSectionView extends StatelessWidget {
  final bool isHorseActive;
  final ValueChanged<bool> onToggleHorseActive;

  const ProfileHorseActiveSectionView({
    required this.isHorseActive,
    required this.onToggleHorseActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Status do Anuncio',
            style: TextStyle(
              color: AppThemeColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: () => onToggleHorseActive(!isHorseActive),
            icon: const Icon(Icons.lock_outline),
            label: Text(isHorseActive ? 'Desativar Cavalo' : 'Ativar Cavalo'),
          ),
        ],
      ),
    );
  }
}
