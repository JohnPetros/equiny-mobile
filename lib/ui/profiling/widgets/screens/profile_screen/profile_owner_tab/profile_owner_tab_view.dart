import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_verified_section/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileOwnerTabView extends StatelessWidget {
  final FormGroup form;
  final bool isLoading;
  final String? generalError;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final String? avatarError;
  final VoidCallback onPickAvatar;
  final VoidCallback onReplaceAvatar;
  final VoidCallback onRemoveAvatar;

  const ProfileOwnerTabView({
    required this.form,
    required this.isLoading,
    required this.generalError,
    required this.avatarUrl,
    required this.isUploadingAvatar,
    required this.avatarError,
    required this.onPickAvatar,
    required this.onReplaceAvatar,
    required this.onRemoveAvatar,
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
            if ((generalError ?? '').isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppThemeColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppThemeColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  generalError!,
                  style: const TextStyle(color: AppThemeColors.errorText),
                ),
              ),
            ProfileOwnerFormSection(
              form: form,
              avatarUrl: avatarUrl,
              isUploadingAvatar: isUploadingAvatar,
              avatarError: avatarError,
              onPickAvatar: onPickAvatar,
              onReplaceAvatar: onReplaceAvatar,
              onRemoveAvatar: onRemoveAvatar,
            ),
            const SizedBox(height: AppSpacing.lg),
            const ProfileOwnerVerifiedSection(),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
