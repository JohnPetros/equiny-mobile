import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileHorseGalleryView extends StatelessWidget {
  final List<ImageDto> images;
  final bool isUploading;
  final bool isSyncing;
  final int maxImages;
  final String? errorMessage;
  final VoidCallback onAddImages;
  final void Function(ImageDto image) onSetPrimary;
  final void Function(ImageDto image) onRemoveImage;
  final VoidCallback onRetrySync;

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
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Galeria do cavalo',
                  style: TextStyle(
                    color: AppThemeColors.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '${images.length}/$maxImages',
                style: const TextStyle(color: AppThemeColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: isUploading || images.length >= maxImages
                ? null
                : onAddImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(isUploading ? 'Enviando...' : 'Adicionar imagens'),
          ),
          if (isSyncing) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Sincronizando galeria...',
              style: TextStyle(color: AppThemeColors.textSecondary),
            ),
          ],
          if (errorMessage != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              errorMessage!,
              style: const TextStyle(color: AppThemeColors.errorText),
            ),
            TextButton(
              onPressed: onRetrySync,
              child: const Text('Tentar novamente'),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (images.isEmpty)
            const Text(
              'Nenhuma imagem cadastrada.',
              style: TextStyle(color: AppThemeColors.textSecondary),
            )
          else
            Column(
              children: images.asMap().entries.map((
                MapEntry<int, ImageDto> entry,
              ) {
                final int index = entry.key;
                final ImageDto image = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppThemeColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppThemeColors.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        index == 0 ? Icons.star : Icons.image_outlined,
                        color: index == 0
                            ? AppThemeColors.primary
                            : AppThemeColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          image.name.isEmpty ? image.key : image.name,
                          style: const TextStyle(
                            color: AppThemeColors.textMain,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: index == 0
                            ? null
                            : () => onSetPrimary(image),
                        child: const Text('Principal'),
                      ),
                      IconButton(
                        onPressed: () => onRemoveImage(image),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
