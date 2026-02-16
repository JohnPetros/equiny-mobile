import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OnboardingStepImagesView extends StatelessWidget {
  final List<ImageDto> images;
  final bool isUploading;
  final String? errorMessage;
  final VoidCallback onAddImages;
  final VoidCallback onRetry;
  final void Function(ImageDto image) onRemoveImage;

  const OnboardingStepImagesView({
    required this.images,
    required this.isUploading,
    required this.errorMessage,
    required this.onAddImages,
    required this.onRetry,
    required this.onRemoveImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppThemeColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Adicione fotos do seu cavalo',
            style: TextStyle(
              color: AppThemeColors.textMain,
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Envie pelo menos 1 imagem para concluir o perfil. Fotos de alta qualidade atraem mais interesse.',
            style: TextStyle(color: AppThemeColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: AppThemeColors.backgroundAlt,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppThemeColors.border),
            ),
            child: OutlinedButton.icon(
              onPressed: isUploading ? null : onAddImages,
              icon: const Icon(Icons.add),
              label: Text(isUploading ? 'Enviando...' : 'Adicionar foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeColors.textMain,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (errorMessage != null) ...<Widget>[
            Text(
              errorMessage!,
              style: const TextStyle(color: AppThemeColors.errorText),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: isUploading ? null : onRetry,
              child: const Text('Tentar novamente'),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (images.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppThemeColors.backgroundAlt,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppThemeColors.border),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(
                    Icons.image_outlined,
                    color: AppThemeColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Nenhuma imagem enviada ainda.',
                      style: TextStyle(color: AppThemeColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: images
                  .map(
                    (ImageDto image) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppThemeColors.border),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.image,
                            color: AppThemeColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              image.name.isEmpty ? image.key : image.name,
                              style: const TextStyle(
                                color: AppThemeColors.textMain,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppThemeColors.primary,
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => onRemoveImage(image),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppThemeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Formatos suportados: JPEG, PNG. Max 10MB.',
            style: TextStyle(color: AppThemeColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
