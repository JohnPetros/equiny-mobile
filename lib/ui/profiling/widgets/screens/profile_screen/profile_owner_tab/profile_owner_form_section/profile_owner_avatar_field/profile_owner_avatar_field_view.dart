import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileOwnerAvatarFieldView extends StatelessWidget {
  final String? avatarUrl;
  final bool isUploading;
  final String? errorMessage;
  final VoidCallback onPickAvatar;
  final VoidCallback onReplaceAvatar;
  final VoidCallback onRemoveAvatar;
  final ProfileOwnerAvatarFieldPresenter _presenter;

  const ProfileOwnerAvatarFieldView({
    required this.avatarUrl,
    required this.isUploading,
    required this.errorMessage,
    required this.onPickAvatar,
    required this.onReplaceAvatar,
    required this.onRemoveAvatar,
    super.key,
  }) : _presenter = const ProfileOwnerAvatarFieldPresenter();

  @override
  Widget build(BuildContext context) {
    final String resolvedAvatarUrl = _presenter.resolveAvatarUrl(avatarUrl);
    final bool hasAvatar = _presenter.isAvatarAvailable(resolvedAvatarUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isUploading
              ? null
              : hasAvatar
              ? onReplaceAvatar
              : onPickAvatar,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppThemeColors.primary, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppThemeColors.primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE7D8C8),
                      border: Border.all(color: AppThemeColors.inputBackground),
                    ),
                    child: hasAvatar
                        ? ClipOval(
                            child: Image.network(
                              resolvedAvatarUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const _AvatarPlaceholder(),
                            ),
                          )
                        : const _AvatarPlaceholder(),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppThemeColors.primary,
                    border: Border.all(
                      color: AppThemeColors.background,
                      width: 2,
                    ),
                  ),
                  child: isUploading
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.black,
                        ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: isUploading
              ? null
              : hasAvatar
              ? onReplaceAvatar
              : onPickAvatar,
          child: Text(
            _presenter.resolveActionLabel(
              avatarUrl: resolvedAvatarUrl,
              isUploading: isUploading,
            ),
          ),
        ),
        if (hasAvatar)
          TextButton(
            onPressed: isUploading ? null : onRemoveAvatar,
            child: const Text(
              'Remover foto',
              style: TextStyle(color: AppThemeColors.errorText),
            ),
          ),
        if ((errorMessage ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppThemeColors.errorText,
                fontSize: AppFontSize.xs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, size: 64, color: Color(0xFF6B5240));
  }
}
