import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/gallery_skeleton/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/gallery_slot/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileHorseGalleryView extends StatelessWidget {
  final List<ImageDto> images;
  final bool isUploading;
  final bool isSyncing;
  final int maxImages;
  final String? errorMessage;
  final VoidCallback onAddImages;
  final VoidCallback onRetrySync;
  final void Function(ImageDto image) onSetPrimary;
  final void Function(ImageDto image) onRemoveImage;

  const ProfileHorseGalleryView({
    required this.images,
    required this.isUploading,
    required this.isSyncing,
    required this.maxImages,
    required this.errorMessage,
    required this.onAddImages,
    required this.onSetPrimary,
    required this.onRemoveImage,
    required this.onRetrySync,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool shouldShowSkeleton = isUploading || isSyncing;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'GALERIA',
                style: TextStyle(
                  color: AppThemeColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: isUploading || images.length >= maxImages
                    ? null
                    : onAddImages,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  isUploading ? 'Enviando...' : 'Adicionar',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          if (isSyncing) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Sincronizando galeria...',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          if (errorMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: AppThemeColors.errorText,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: onRetrySync,
              child: const Text('Tentar novamente'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (shouldShowSkeleton)
            GallerySkeleton(maxImages: maxImages)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List<Widget>.generate(maxImages, (int index) {
                return GallerySlot(
                  slotIndex: index,
                  images: images,
                  maxImages: maxImages,
                  isUploading: isUploading,
                  onAdd: onAddImages,
                  onSetPrimary: onSetPrimary,
                  onRemove: onRemoveImage,
                );
              }),
            ),
        ],
      ),
    );
  }
}
