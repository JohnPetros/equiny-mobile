import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart';

class OnboardingStepLocationView extends ConsumerStatefulWidget {
  final FormGroup form;
  final bool submitAttempted;

  const OnboardingStepLocationView({
    required this.form,
    required this.submitAttempted,
    super.key,
  });

  @override
  ConsumerState<OnboardingStepLocationView> createState() =>
      _OnboardingStepLocationViewState();
}

class _OnboardingStepLocationViewState
    extends ConsumerState<OnboardingStepLocationView> {
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingStepLocationPresenterProvider).loadStates();
    });

    _stateController.text = widget.form.control('state').value as String? ?? '';
    _cityController.text = widget.form.control('city').value as String? ?? '';

    _stateController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final String state = _stateController.text;
    widget.form.control('state').value = state;

    if (state.isNotEmpty) {
      ref.read(onboardingStepLocationPresenterProvider).loadCities(state);
    }
  }

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presenter = ref.watch(onboardingStepLocationPresenterProvider);
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
      child: ReactiveForm(
        formGroup: widget.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Onde ele esta localizado?',
              style: TextStyle(
                color: AppThemeColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Informe a cidade e o estado.',
              style: TextStyle(
                color: AppThemeColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Watch((context) {
              final isLoading = presenter.isLoadingStates.value;
              final states = presenter.states.value;

              return Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return states;
                  }
                  return presenter.filterStates(textEditingValue.text);
                },
                onSelected: (String selection) {
                  _stateController.text = selection;
                  widget.form.control('state').value = selection;
                  presenter.loadCities(selection);
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      fieldTextEditingController.text = _stateController.text;
                      fieldTextEditingController.selection =
                          _stateController.selection;

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: focusNode,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: AppThemeColors.textMain),
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          suffixIcon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.map,
                                  color: AppThemeColors.primary,
                                ),
                        ),
                        onChanged: (value) {
                          _stateController.text = value;
                          _stateController.selection =
                              fieldTextEditingController.selection;
                        },
                      );
                    },
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            Watch((context) {
              final isLoading = presenter.isLoadingCities.value;
              final cities = presenter.cities.value;

              return Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return cities;
                  }
                  return presenter.filterCities(textEditingValue.text);
                },
                onSelected: (String selection) {
                  _cityController.text = selection;
                  widget.form.control('city').value = selection;
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      fieldTextEditingController.text = _cityController.text;
                      fieldTextEditingController.selection =
                          _cityController.selection;

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: focusNode,
                        style: const TextStyle(color: AppThemeColors.textMain),
                        decoration: InputDecoration(
                          labelText: 'Cidade',
                          suffixIcon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.location_city,
                                  color: AppThemeColors.primary,
                                ),
                        ),
                        onChanged: (value) {
                          _cityController.text = value;
                          _cityController.selection =
                              fieldTextEditingController.selection;
                        },
                      );
                    },
              );
            }),
            const SizedBox(height: AppSpacing.xs),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppThemeColors.textSecondary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Isso ajuda a personalizar sua experiencia e encontrar compradores proximos.',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
