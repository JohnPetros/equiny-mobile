import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/field_label/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/sex_button/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

const List<DropdownMenuItem<String>> _breedOptions = <DropdownMenuItem<String>>[
  DropdownMenuItem<String>(value: '', child: Text('Selecione uma raca')),
  DropdownMenuItem<String>(
    value: 'quarto de milha',
    child: Text('Quarto de Milha'),
  ),
  DropdownMenuItem<String>(
    value: 'mangalarga marchador',
    child: Text('Mangalarga Marchador'),
  ),
  DropdownMenuItem<String>(value: 'criolo', child: Text('Crioulo')),
  DropdownMenuItem<String>(
    value: 'puro sangue inglês',
    child: Text('Puro Sangue Inglês'),
  ),
  DropdownMenuItem<String>(value: 'arabe', child: Text('Arabe')),
  DropdownMenuItem<String>(value: 'campolina', child: Text('Campolina')),
  DropdownMenuItem<String>(value: 'outra', child: Text('Outra')),
];

class ProfileHorseFormSectionView extends StatelessWidget {
  const ProfileHorseFormSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int currentYear = DateTime.now().year;
    final List<DropdownMenuItem<int>> birthYearOptions =
        List<DropdownMenuItem<int>>.generate(41, (int index) {
          final int year = currentYear - index;
          return DropdownMenuItem<int>(value: year, child: Text('$year'));
        });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'DADOS DO CAVALO',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppThemeColors.textSecondary,
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Nome Oficial'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: _pillDecoration(hintText: 'Royal Legend'),
            validationMessages: <String, ValidationMessageFunction>{
              ValidationMessage.required: (_) => 'Informe o nome',
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Sexo'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveValueListenableBuilder<String>(
            formControlName: 'sex',
            builder:
                (
                  BuildContext context,
                  AbstractControl<String> control,
                  Widget? child,
                ) {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: SexButton(
                          label: 'Macho',
                          selected: control.value == 'male',
                          onTap: () => control.value = 'male',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SexButton(
                          label: 'Femea',
                          selected: control.value == 'female',
                          onTap: () => control.value = 'female',
                        ),
                      ),
                    ],
                  );
                },
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Raça'),
          const SizedBox(height: AppSpacing.xs),
          ReactiveDropdownField<String>(
            formControlName: 'breed',
            isExpanded: true,
            items: _breedOptions,
            decoration: _pillDecoration(
              hintText: 'Selecione a raca',
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppThemeColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const FieldLabel('Nascimento'),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Expanded(
                child: ReactiveTextField<int>(
                  formControlName: 'birthMonth',
                  decoration: _pillDecoration(hintText: 'Mes'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ReactiveDropdownField<int>(
                  formControlName: 'birthYear',
                  isExpanded: true,
                  items: birthYearOptions,
                  decoration: _pillDecoration(
                    hintText: 'Ano',
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppThemeColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ReactiveValueListenableBuilder<double>(
            formControlName: 'height',
            builder:
                (
                  BuildContext context,
                  AbstractControl<double> control,
                  Widget? child,
                ) {
                  final double heightValue = (control.value ?? 1.65).clamp(
                    0.5,
                    3.0,
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppThemeColors.inputBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Altura',
                                style: TextStyle(
                                  color: AppThemeColors.textMain,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${heightValue.toStringAsFixed(2)}m',
                              style: const TextStyle(
                                color: AppThemeColors.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppThemeColors.primary,
                            inactiveTrackColor: AppThemeColors.inputBorder,
                            thumbColor: AppThemeColors.primary,
                            overlayColor: AppThemeColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            min: 0.5,
                            max: 3,
                            value: heightValue,
                            onChanged: (double value) => control.value = value,
                          ),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'PONEI',
                              style: TextStyle(
                                color: AppThemeColors.textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'MEDIO',
                              style: TextStyle(
                                color: AppThemeColors.textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'ALTO',
                              style: TextStyle(
                                color: AppThemeColors.textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: ReactiveTextField<String>(
                  formControlName: 'city',
                  decoration: _pillDecoration(hintText: 'Cidade'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ReactiveTextField<String>(
                  formControlName: 'state',
                  decoration: _pillDecoration(hintText: 'UF'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ReactiveTextField<String>(
            formControlName: 'description',
            maxLines: 3,
            decoration: _pillDecoration(
              hintText: 'Informacoes importantes sobre o cavalo',
              borderRadius: 16,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _pillDecoration({
  String? hintText,
  Widget? suffixIcon,
  double borderRadius = 999,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AppThemeColors.textSecondary,
      fontWeight: FontWeight.w500,
      fontSize: 16,
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
