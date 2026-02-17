import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_active_section/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart';
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
  final int maxImages;
  final List<String> feedReadinessChecklist;
  final String? horseErrorMessage;
  final String? galleryErrorMessage;
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
    this.maxImages = ProfileHorseTabPresenter.maxImages,
    required this.feedReadinessChecklist,
    required this.horseErrorMessage,
    required this.galleryErrorMessage,
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
              maxImages: maxImages,
              errorMessage: galleryErrorMessage,
              onAddImages: onAddImages,
              onSetPrimary: onSetPrimary,
              onRemoveImage: onRemoveImage,
              onRetrySync: onRetryGallerySync,
            ),
            if ((horseErrorMessage ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                horseErrorMessage!,
                style: const TextStyle(
                  color: AppThemeColors.errorText,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const ProfileHorseFormSection(),
            const SizedBox(height: AppSpacing.md),
            ProfileHorseFeedReadinessSection(
              feedReadinessChecklist: feedReadinessChecklist,
            ),
            const SizedBox(height: AppSpacing.md),
            ProfileHorseActiveSection(
              isHorseActive: isHorseActive,
              onToggleHorseActive: onToggleHorseActive,
            ),
          ],
        ),
      ),
    );
  }
}
