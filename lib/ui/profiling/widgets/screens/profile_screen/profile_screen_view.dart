import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab_placeholder/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_tab_selector/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ProfileScreenView extends ConsumerWidget {
  const ProfileScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(profileScreenPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Perfil'),
        leading: IconButton(
          onPressed: presenter.goBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Watch((BuildContext context) {
                final String syncStatus =
                    presenter.isSyncingHorse.value ||
                        presenter.isSyncingGallery.value
                    ? 'Sincronizando...'
                    : presenter.lastSyncAt.value != null
                    ? 'Sincronizado'
                    : 'Aguardando sincronizacao';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      syncStatus,
                      style: const TextStyle(
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ProfileTabSelector(
                      activeTab: presenter.activeTab.value,
                      onTabChanged: presenter.switchTab,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: presenter.isHorseTab.value
                          ? ProfileHorseTab(
                              form: presenter.horseForm.value,
                              images: presenter.horseImages.value,
                              isHorseActive: presenter.isHorseActive.value,
                              isLoading: presenter.isLoadingInitialData.value,
                              isUploading: presenter.isUploadingImages.value,
                              isSyncingGallery:
                                  presenter.isSyncingGallery.value,
                              feedReadinessChecklist:
                                  presenter.feedReadinessChecklist.value,
                              errorMessage: presenter.generalError.value,
                              onAddImages: presenter.pickAndUploadImages,
                              onSetPrimary: presenter.setPrimaryImage,
                              onRemoveImage: presenter.removeImage,
                              onRetryGallerySync: () => presenter.syncGallery(),
                              onToggleHorseActive: (bool value) =>
                                  presenter.toggleHorseActive(value),
                            )
                          : const ProfileOwnerTabPlaceholder(),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
