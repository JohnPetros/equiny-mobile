import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InboxScreenEmptyStateView extends StatelessWidget {
  final VoidCallback onGoToMatches;

  const InboxScreenEmptyStateView({required this.onGoToMatches, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Conversas',
              style: TextStyle(
                fontSize: AppFontSize.xxxxl,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: <Color>[
                                AppThemeColors.primary.withValues(alpha: 0.28),
                                AppThemeColors.primary.withValues(alpha: 0.04),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppThemeColors.primary.withValues(
                                alpha: 0.33,
                              ),
                            ),
                            color: AppThemeColors.primary.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: AppThemeColors.primary,
                            size: 42,
                          ),
                        ),
                        Positioned(right: 18, top: 6, child: _Orb(size: 16)),
                        Positioned(left: 26, bottom: 24, child: _Orb(size: 12)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Text(
                      'Sem conversas ainda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFontSize.xxl,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textMain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Para comecar uma conversa, va ate\nMatches e envie sua primeira mensagem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFontSize.md,
                        color: AppThemeColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onGoToMatches,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Ir para Matches'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;

  const _Orb({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppThemeColors.primary.withValues(alpha: 0.7),
        border: Border.all(
          color: AppThemeColors.primary.withValues(alpha: 0.25),
          width: 4,
        ),
      ),
    );
  }
}
