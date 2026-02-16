import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_actions/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_progress_header/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_birth/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_breed/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_images/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_height/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_name/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_sex/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class OnboardingScreenView extends ConsumerWidget {
  const OnboardingScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(onboardingScreenPresenterProvider);
    final List<int> months = List<int>.generate(12, (int index) => index + 1);
    final int currentYear = DateTime.now().year;
    final List<int> years = List<int>.generate(
      currentYear - 1979,
      (int index) => currentYear - index,
    );

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Watch((BuildContext context) {
                final int currentStep = presenter.currentStepIndex.value;
                final bool isLoading =
                    presenter.isSubmitting.value ||
                    presenter.isUploadingImages.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    OnboardingProgressHeader(
                      stepIndex: currentStep,
                      totalSteps: OnboardingScreenPresenter.totalSteps,
                      title: _stepTitle(currentStep),
                      subtitle: _stepSubtitle(currentStep),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: SingleChildScrollView(
                        child: IndexedStack(
                          index: currentStep,
                          children: <Widget>[
                            OnboardingStepName(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                            ),
                            OnboardingStepBirth(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                              availableMonths: months,
                              availableYears: years,
                            ),
                            OnboardingStepBreed(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                              breedOptions: presenter.breedOptions,
                            ),
                            OnboardingStepSex(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                              sexOptions: presenter.sexOptions,
                            ),
                            OnboardingStepHeight(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                            ),
                            OnboardingStepLocation(
                              form: presenter.form.value,
                              submitAttempted: presenter.submitAttempted.value,
                            ),
                            OnboardingStepImages(
                              images: presenter.uploadedImages.value,
                              isUploading: presenter.isUploadingImages.value,
                              errorMessage: presenter.generalError.value,
                              onAddImages: presenter.pickAndUploadImages,
                              onRetry: presenter.retryImageUpload,
                              onRemoveImage: presenter.removeImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (presenter.generalError.value != null &&
                        currentStep != 6)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          presenter.generalError.value!,
                          style: const TextStyle(
                            color: AppThemeColors.errorText,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    OnboardingActions(
                      isFirstStep: presenter.isFirstStep.value,
                      isLastStep: presenter.isLastStep.value,
                      canAdvance: presenter.canAdvance.value,
                      canFinish: presenter.canFinish.value,
                      isLoading: isLoading,
                      onBack: presenter.goPreviousStep,
                      onNext: presenter.goNextStep,
                      onFinish: presenter.submitOnboarding,
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

  String _stepTitle(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return 'Cadastre seu primeiro cavalo';
      case 1:
        return 'Quando ele nasceu?';
      case 2:
        return 'Qual a raca?';
      case 3:
        return 'Qual o sexo?';
      case 4:
        return 'Qual e a altura dele?';
      case 5:
        return 'Onde ele esta?';
      case 6:
        return 'Envie fotos do cavalo';
      default:
        return '';
    }
  }

  String _stepSubtitle(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return '';
      case 1:
        return 'Use mes e ano aproximados caso nao saiba a data exata.';
      case 2:
        return 'Escolha a raca principal para melhorar os matches.';
      case 3:
        return 'Essa informacao e usada nos filtros de descoberta.';
      case 4:
        return 'Use uma medida aproximada em metros.';
      case 5:
        return 'Cidade e UF ajudam a mostrar perfis mais relevantes.';
      case 6:
        return 'Adicione ao menos uma imagem para concluir o cadastro.';
      default:
        return '';
    }
  }
}
