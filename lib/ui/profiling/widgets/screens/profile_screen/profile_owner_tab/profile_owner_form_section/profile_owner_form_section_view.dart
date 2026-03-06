import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/field_label/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/section_header/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileOwnerFormSectionView extends StatelessWidget {
  final FormGroup form;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final String? avatarError;
  final VoidCallback onPickAvatar;
  final VoidCallback onReplaceAvatar;
  final VoidCallback onRemoveAvatar;

  const ProfileOwnerFormSectionView({
    required this.form,
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
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProfileOwnerSectionHeader(theme: theme, title: 'DADOS PESSOAIS'),
          const SizedBox(height: AppSpacing.md),
          ProfileOwnerAvatarField(
            avatarUrl: avatarUrl,
            isUploading: isUploadingAvatar,
            errorMessage: avatarError,
            onPickAvatar: onPickAvatar,
            onReplaceAvatar: onReplaceAvatar,
            onRemoveAvatar: onRemoveAvatar,
          ),
          const SizedBox(height: AppSpacing.xl),
          const ProfileOwnerFieldLabel(text: 'Nome Completo'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveTextField<String>(
            formControlName: 'name',
            textInputAction: TextInputAction.done,
            decoration: _pillDecoration(
              hintText: 'Seu nome completo',
              suffixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppThemeColors.primary,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.black),
              ),
            ),
            validationMessages: <String, ValidationMessageFunction>{
              ValidationMessage.required: (_) => 'Informe seu nome completo',
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileOwnerSectionHeader(theme: theme, title: 'CONTATO'),
          const SizedBox(height: AppSpacing.md),
          const ProfileOwnerFieldLabel(text: 'Email'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveTextField<String>(
            formControlName: 'email',
            readOnly: true,
            decoration: _pillDecoration(hintText: 'seuemail@email.com'),
          ),
          const SizedBox(height: AppSpacing.md),
          ReactiveValueListenableBuilder<String>(
            formControlName: 'phone',
            builder:
                (
                  BuildContext context,
                  AbstractControl<String> control,
                  Widget? child,
                ) {
                  final String phoneValue = (control.value ?? '').trim();
                  final bool hasPhone = phoneValue.isNotEmpty;
                  final bool isPhoneInvalid =
                      hasPhone && !_isValidPhone(phoneValue);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Telefone',
                        style: TextStyle(
                          color: isPhoneInvalid
                              ? const Color(0xFFFF4D5E)
                              : AppThemeColors.textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isPhoneInvalid
                                ? const Color(0xFFFF4D5E)
                                : Colors.transparent,
                          ),
                        ),
                        child: ReactiveTextField<String>(
                          formControlName: 'phone',
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          showErrors: (_) => false,
                          decoration: _pillDecoration(
                            hintText: hasPhone ? phoneValue : 'Nao informado',
                            suffixIcon: isPhoneInvalid
                                ? Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFF4D5E),
                                    ),
                                    child: const Icon(
                                      Icons.priority_high_rounded,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      if (isPhoneInvalid) ...<Widget>[
                        const SizedBox(height: AppSpacing.xxs),
                        const Text(
                          'Telefone invalido - insira 11 digitos',
                          style: TextStyle(
                            color: Color(0xFFFF4D5E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                },
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileOwnerSectionHeader(theme: theme, title: 'SOBRE VOCE'),
          const SizedBox(height: AppSpacing.md),
          const ProfileOwnerFieldLabel(text: 'Bio'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveValueListenableBuilder<String>(
            formControlName: 'bio',
            builder:
                (
                  BuildContext context,
                  AbstractControl<String> control,
                  Widget? child,
                ) {
                  final String bioValue = (control.value ?? '').trim();
                  final int bioLength = bioValue.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ReactiveTextField<String>(
                        formControlName: 'bio',
                        minLines: 3,
                        maxLines: 3,
                        decoration: _pillDecoration(
                          hintText: bioValue.isEmpty
                              ? 'Sem descricao no momento'
                              : bioValue,
                          borderRadius: 26,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$bioLength/300',
                          style: const TextStyle(
                            color: Color(0xFF5D78A8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
          ),
        ],
      ),
    );
  }

  bool _isValidPhone(String value) {
    final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length == 11;
  }
}

InputDecoration _pillDecoration({
  required String hintText,
  Widget? suffixIcon,
  double borderRadius = 999,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AppThemeColors.textSecondary,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    filled: true,
    fillColor: AppThemeColors.inputBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: AppThemeColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: AppThemeColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: AppThemeColors.error),
    ),
    suffixIcon: suffixIcon,
  );
}
