import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart';
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
    final screenPresenter = ref.watch(profileScreenPresenterProvider);
    final horseTabPresenter = ref.watch(profileHorseTabPresenterProvider);
    final ownerTabPresenter = ref.watch(profileOwnerTabPresenterProvider);

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      appBar: AppBar(
        backgroundColor: AppThemeColors.background,
        title: const Text('Perfil'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value != 'logout') {
                return;
              }
              await screenPresenter.logout();
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    spacing: AppSpacing.xxs,
                    children: [Icon(Icons.logout), Text('Sair da conta')],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Watch((BuildContext context) {
                final String syncStatus = screenPresenter.isHorseTab.value
                    ? horseTabPresenter.isSyncingHorse.value ||
                              horseTabPresenter.isSyncingGallery.value
                          ? 'Sincronizando...'
                          : horseTabPresenter.lastSyncAt.value != null
                          ? 'Sincronizado'
                          : 'Aguardando sincronizacao'
                    : ownerTabPresenter.isSyncingOwner.value
                    ? 'Sincronizando...'
                    : ownerTabPresenter.lastSyncAt.value != null
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
                      activeTab: screenPresenter.activeTab.value,
                      onTabChanged: screenPresenter.switchTab,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: screenPresenter.isHorseTab.value
                          ? ProfileHorseTab(
                              form: horseTabPresenter.horseForm.value,
                              images: horseTabPresenter.horseImages.value,
                              isHorseActive:
                                  horseTabPresenter.isHorseActive.value,
                              isLoading:
                                  horseTabPresenter.isLoadingInitialData.value,
                              isUploading:
                                  horseTabPresenter.isUploadingImages.value,
                              isSyncingGallery:
                                  horseTabPresenter.isSyncingGallery.value,
                              maxImages: ProfileHorseTabPresenter.maxImages,
                              feedReadinessChecklist: horseTabPresenter
                                  .feedReadinessChecklist
                                  .value,
                              horseErrorMessage:
                                  horseTabPresenter.generalError.value,
                              galleryErrorMessage:
                                  horseTabPresenter.galleryError.value,
                              onAddImages:
                                  horseTabPresenter.pickAndUploadImages,
                              onSetPrimary: horseTabPresenter.setPrimaryImage,
                              onRemoveImage: horseTabPresenter.removeImage,
                              onRetryGallerySync: () =>
                                  horseTabPresenter.syncGallery(),
                              onToggleHorseActive: (bool value) =>
                                  horseTabPresenter.toggleHorseActive(value),
                            )
                          : ProfileOwnerTab(
                              form: ownerTabPresenter.ownerForm.value,
                              isLoading: ownerTabPresenter.isLoadingOwner.value,
                              generalError:
                                  ownerTabPresenter.generalError.value,
                              avatarUrl: ownerTabPresenter.ownerAvatarUrl.value,
                              isUploadingAvatar:
                                  ownerTabPresenter.isUploadingAvatar.value,
                              avatarError: ownerTabPresenter.avatarError.value,
                              onPickAvatar:
                                  ownerTabPresenter.pickAndUploadAvatar,
                              onReplaceAvatar: ownerTabPresenter.replaceAvatar,
                              onRemoveAvatar: ownerTabPresenter.removeAvatar,
                            ),
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
