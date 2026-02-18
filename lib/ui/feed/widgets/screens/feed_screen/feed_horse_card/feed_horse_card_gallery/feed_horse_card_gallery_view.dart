import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FeedHorseCardGalleryView extends StatelessWidget {
  final String? imageUrl;
  final int imageCount;
  final int currentImageIndex;
  final VoidCallback onNextImage;
  final VoidCallback onPreviousImage;

  const FeedHorseCardGalleryView({
    required this.imageUrl,
    required this.imageCount,
    required this.currentImageIndex,
    required this.onNextImage,
    required this.onPreviousImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: imageUrl == null || imageUrl!.isEmpty
              ? Container(
                  color: AppThemeColors.backgroundAlt,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                )
              : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppThemeColors.backgroundAlt,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
        ),
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: _GalleryProgress(
            imageCount: imageCount,
            currentImageIndex: currentImageIndex,
          ),
        ),
        Positioned.fill(
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onPreviousImage,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onNextImage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryProgress extends StatelessWidget {
  final int imageCount;
  final int currentImageIndex;

  const _GalleryProgress({
    required this.imageCount,
    required this.currentImageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final int total = imageCount <= 0 ? 1 : imageCount;

    return Row(
      children: List<Widget>.generate(total, (int index) {
        final bool isActive = index == currentImageIndex;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}
