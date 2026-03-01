import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MatchHorseAvatarView extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const MatchHorseAvatarView({
    required this.imageUrl,
    this.size = 176,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = imageUrl?.trim() ?? '';
    final bool hasImage = resolvedImageUrl.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppThemeColors.primary,
                  AppThemeColors.primaryDark,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppThemeColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppThemeColors.backgroundAlt,
                border: Border.all(color: AppThemeColors.surface, width: 3),
              ),
              child: ClipOval(
                child: hasImage
                    ? Image.network(
                        resolvedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 8,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppThemeColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppThemeColors.border, width: 2),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppThemeColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppThemeColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.pets,
        color: AppThemeColors.textSecondary,
        size: 44,
      ),
    );
  }
}
