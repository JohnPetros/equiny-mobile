import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/profile_owner_avatar_source_sheet_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileOwnerAvatarSourceSheetView extends StatelessWidget {
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback? onRemovePhoto;
  final bool showRemoveOption;
  final ProfileOwnerAvatarSourceSheetPresenter _presenter;

  const ProfileOwnerAvatarSourceSheetView({
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.showRemoveOption,
    this.onRemovePhoto,
    super.key,
  }) : _presenter = const ProfileOwnerAvatarSourceSheetPresenter();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPickFromCamera,
    required VoidCallback onPickFromGallery,
    required bool showRemoveOption,
    VoidCallback? onRemovePhoto,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppThemeColors.surface,
      builder: (BuildContext context) {
        return ProfileOwnerAvatarSourceSheetView(
          onPickFromCamera: onPickFromCamera,
          onPickFromGallery: onPickFromGallery,
          onRemovePhoto: onRemovePhoto,
          showRemoveOption: showRemoveOption,
        );
      },
    );
  }

  void _handleAction(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final List<ProfileOwnerAvatarSourceOption> options = _presenter
        .buildOptions(
          showGalleryOption: true,
          showRemoveOption: showRemoveOption,
        );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              _presenter.resolveTitle(),
              style: const TextStyle(
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.textMain,
              ),
            ),
          ),
          for (final ProfileOwnerAvatarSourceOption option in options)
            ListTile(
              leading: Icon(
                _resolveIcon(option.type),
                color: option.isDestructive
                    ? AppThemeColors.errorText
                    : AppThemeColors.textMain,
              ),
              title: Text(
                option.title,
                style: TextStyle(
                  color: option.isDestructive
                      ? AppThemeColors.errorText
                      : AppThemeColors.textMain,
                ),
              ),
              onTap: () {
                if (option.type == ProfileOwnerAvatarSourceOptionType.camera) {
                  _handleAction(context, onPickFromCamera);
                  return;
                }

                if (option.type == ProfileOwnerAvatarSourceOptionType.gallery) {
                  _handleAction(context, onPickFromGallery);
                  return;
                }

                if (onRemovePhoto != null) {
                  _handleAction(context, onRemovePhoto!);
                }
              },
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  IconData _resolveIcon(ProfileOwnerAvatarSourceOptionType type) {
    switch (type) {
      case ProfileOwnerAvatarSourceOptionType.camera:
        return Icons.photo_camera_outlined;
      case ProfileOwnerAvatarSourceOptionType.gallery:
        return Icons.photo_library_outlined;
      case ProfileOwnerAvatarSourceOptionType.remove:
        return Icons.delete_outline;
    }
  }
}
