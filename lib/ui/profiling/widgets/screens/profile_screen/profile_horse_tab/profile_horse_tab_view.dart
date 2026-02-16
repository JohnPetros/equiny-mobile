import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileHorseTabView extends StatelessWidget {
  final FormGroup form;
  final List<ImageDto> images;
  final bool isHorseActive;
  final bool isLoading;
  final bool isUploading;
  final bool isSyncingGallery;
  final List<String> feedReadinessChecklist;
  final String? errorMessage;
  final VoidCallback onAddImages;
  final void Function(ImageDto image) onSetPrimary;
  final void Function(ImageDto image) onRemoveImage;
  final VoidCallback onRetryGallerySync;
  final ValueChanged<bool> onToggleHorseActive;

  const ProfileHorseTabView({
    required this.form,
    required this.images,
    required this.isHorseActive,
    required this.isLoading,
    required this.isUploading,
    required this.isSyncingGallery,
    required this.feedReadinessChecklist,
    required this.errorMessage,
    required this.onAddImages,
    required this.onSetPrimary,
    required this.onRemoveImage,
    required this.onRetryGallerySync,
    required this.onToggleHorseActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ReactiveForm(
      formGroup: form,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ProfileHorseGallery(
              images: images,
              isUploading: isUploading,
              isSyncing: isSyncingGallery,
              maxImages: 6,
              errorMessage: errorMessage,
              onAddImages: onAddImages,
              onSetPrimary: onSetPrimary,
              onRemoveImage: onRemoveImage,
              onRetrySync: onRetryGallerySync,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFormSection(),
            const SizedBox(height: AppSpacing.md),
            _buildReadinessSection(),
            const SizedBox(height: AppSpacing.md),
            _buildActiveSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
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
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: const InputDecoration(labelText: 'Nome'),
            validationMessages: <String, ValidationMessageFunction>{
              ValidationMessage.required: (_) => 'Informe o nome',
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: ReactiveTextField<int>(
                  formControlName: 'birthMonth',
                  decoration: const InputDecoration(
                    labelText: 'Mes de nascimento',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ReactiveTextField<int>(
                  formControlName: 'birthYear',
                  decoration: const InputDecoration(
                    labelText: 'Ano de nascimento',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'breed',
            decoration: const InputDecoration(labelText: 'Raca'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'sex',
            decoration: const InputDecoration(labelText: 'Sexo'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<double>(
            formControlName: 'height',
            decoration: const InputDecoration(labelText: 'Altura (m)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: ReactiveTextField<String>(
                  formControlName: 'city',
                  decoration: const InputDecoration(labelText: 'Cidade'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ReactiveTextField<String>(
                  formControlName: 'state',
                  decoration: const InputDecoration(labelText: 'UF'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'description',
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descricao'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Pronto para o Feed',
            style: TextStyle(
              color: AppThemeColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (feedReadinessChecklist.isEmpty)
            const Text(
              'Tudo certo. Seu cavalo pode ser ativado no feed.',
              style: TextStyle(color: AppThemeColors.textSecondary),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: feedReadinessChecklist
                  .map(
                    (String item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '- $item',
                        style: const TextStyle(
                          color: AppThemeColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Ativar cavalo no feed',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(value: isHorseActive, onChanged: onToggleHorseActive),
        ],
      ),
    );
  }
}
