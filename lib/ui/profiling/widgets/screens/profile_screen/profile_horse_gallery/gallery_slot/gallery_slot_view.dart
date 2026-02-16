import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/gallery_slot/gallery_slot_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GallerySlotView extends ConsumerWidget {
  final int slotIndex;
  final List<ImageDto> images;
  final int maxImages;
  final bool isUploading;
  final VoidCallback onAdd;
  final void Function(ImageDto image) onSetPrimary;
  final void Function(ImageDto image) onRemove;

  const GallerySlotView({
    required this.slotIndex,
    required this.images,
    required this.maxImages,
    required this.isUploading,
    required this.onAdd,
    required this.onSetPrimary,
    required this.onRemove,
    super.key,
  });

  Future<void> _confirmAndRemoveImage(
    BuildContext context,
    ImageDto image,
  ) async {
    final bool shouldRemove =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Remover imagem?'),
              content: const Text(
                'Essa acao nao pode ser desfeita. Deseja continuar?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Remover'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldRemove) {
      return;
    }

    onRemove(image);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(gallerySlotPresenterProvider);
    final fileStorageDriver = ref.read(fileStorageDriverProvider);

    final hasImage = presenter.hasImage(
      slotIndex: slotIndex,
      totalImages: images.length,
    );

    final image = presenter.getImage(slotIndex: slotIndex, images: images);

    final imageUrl = presenter.getImageUrl(
      image: image,
      getUrlFromKey: fileStorageDriver.getImageUrl,
    );

    final isPrimary = presenter.isPrimary(slotIndex: slotIndex);

    final canSetPrimary = presenter.canSetPrimary(
      slotIndex: slotIndex,
      totalImages: images.length,
    );

    final canRemove = presenter.canRemove(
      slotIndex: slotIndex,
      totalImages: images.length,
    );

    final canAdd = presenter.canAdd(
      slotIndex: slotIndex,
      totalImages: images.length,
      maxImages: maxImages,
      isUploading: isUploading,
    );

    return GestureDetector(
      onTap: canAdd ? onAdd : null,
      child: Stack(
        children: <Widget>[
          Container(
            width: 104,
            height: 136,
            decoration: BoxDecoration(
              color: AppThemeColors.backgroundAlt,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppThemeColors.border, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: hasImage && imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: AppThemeColors.textSecondary,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        hasImage ? Icons.image_outlined : Icons.add,
                        size: hasImage ? 40 : 32,
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
            ),
          ),
          if (isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'PRINCIPAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF222026),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          if (canSetPrimary && image != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => onSetPrimary(image),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeColors.backgroundAlt.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppThemeColors.border),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppThemeColors.textMain,
                  ),
                ),
              ),
            ),
          if (canRemove && image != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _confirmAndRemoveImage(context, image),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppThemeColors.backgroundAlt.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppThemeColors.border),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppThemeColors.textMain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
