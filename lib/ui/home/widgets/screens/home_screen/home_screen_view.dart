import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppThemeColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppThemeColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: AppThemeColors.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Acesse o perfil para editar os dados do cavalo e da galeria.',
                    style: TextStyle(color: AppThemeColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => context.go(Routes.profile),
                    child: const Text('Abrir perfil'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
