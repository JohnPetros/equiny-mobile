import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LocationAutofillCtaView extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final bool showSettingsAction;
  final VoidCallback onTapDetect;
  final VoidCallback onTapOpenSettings;

  const LocationAutofillCtaView({
    required this.isLoading,
    required this.message,
    required this.showSettingsAction,
    required this.onTapDetect,
    required this.onTapOpenSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton.icon(
            onPressed: isLoading ? null : onTapDetect,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              isLoading
                  ? 'Detectando localizacao...'
                  : 'Usar minha localizacao atual',
            ),
          ),
          if ((message ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              style: const TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          if (showSettingsAction) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onTapOpenSettings,
                child: const Text('Abrir configuracoes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
