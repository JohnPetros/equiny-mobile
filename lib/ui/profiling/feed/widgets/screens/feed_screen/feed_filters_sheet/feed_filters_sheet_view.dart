import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_filters_sheet/age_range_slider/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_filters_sheet/breed_chip/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_filters_sheet/city_dropdown/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_filters_sheet/feed_filters_sheet_presenter.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/feed_filters_sheet/state_dropdown/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FeedFiltersSheetView extends ConsumerStatefulWidget {
  final HorseFeedFiltersDto initialFilters;
  final ValueChanged<HorseFeedFiltersDto> onApply;
  final VoidCallback onClear;
  final VoidCallback? onClose;

  const FeedFiltersSheetView({
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
    this.onClose,
    super.key,
  });

  @override
  ConsumerState<FeedFiltersSheetView> createState() =>
      _FeedFiltersSheetViewState();
}

class _FeedFiltersSheetViewState extends ConsumerState<FeedFiltersSheetView> {
  static const List<String> _fallbackBreeds = <String>[
    'quarto de milha',
    'mangalarga marchador',
    'criolo',
    'puro sangue ingles',
    'arabe',
    'campolina',
  ];

  late final FeedFiltersSheetPresenter _presenter;
  final TextEditingController _breedSearchController = TextEditingController();
  List<String> _breeds = <String>[..._fallbackBreeds];

  @override
  void initState() {
    super.initState();
    _presenter = FeedFiltersSheetPresenter(widget.initialFilters);
    _presenter.selectedBreeds.value = _presenter.selectedBreeds.value
        .where((String breed) => breed.toLowerCase().trim() != 'outra')
        .toList();
    _loadBreeds();
  }

  Future<void> _loadBreeds() async {
    final response = await ref.read(profilingServiceProvider).fetchBreeds();
    if (response.isFailure) {
      return;
    }

    final List<String> breeds = response.body
        .map((String breed) => breed.trim())
        .where(
          (String breed) =>
              breed.isNotEmpty && breed.toLowerCase().trim() != 'outra',
        )
        .toSet()
        .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _breeds = breeds;
    });
  }

  @override
  void dispose() {
    _breedSearchController.dispose();
    super.dispose();
  }

  int _getActiveFiltersCount() {
    int count = 0;
    final filters = _presenter.toDto();
    if (filters.location.city.isNotEmpty || filters.location.state.isNotEmpty) {
      count++;
    }
    if (filters.ageRange.min != 1 || filters.ageRange.max != 30) count++;
    if (filters.breeds.isNotEmpty) count++;
    return count;
  }

  String _getAgeRangeLabel() {
    final minAge = _presenter.form.value.control('minAge').value as int? ?? 2;
    final maxAge = _presenter.form.value.control('maxAge').value as int? ?? 12;
    return '$minAge - $maxAge anos';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Watch((BuildContext context) {
        final activeFiltersCount = _getActiveFiltersCount();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text(
                  'Filtros',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                if (activeFiltersCount > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      activeFiltersCount.toString(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222026),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () {
                    widget.onClose?.call();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Faixa de idade',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(
                  _getAgeRangeLabel(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppThemeColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AgeRangeSlider(
              minValue:
                  (_presenter.form.value.control('minAge').value as int?)
                      ?.toDouble() ??
                  2,
              maxValue:
                  (_presenter.form.value.control('maxAge').value as int?)
                      ?.toDouble() ??
                  12,
              onChanged: (min, max) {
                setState(() {
                  _presenter.form.value
                      .control('minAge')
                      .updateValue(min.toInt());
                  _presenter.form.value
                      .control('maxAge')
                      .updateValue(max.toInt());
                });
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Localização',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: StateDropdown(
                    value:
                        (_presenter.form.value.control('state').value
                            as String?) ??
                        '',
                    onChanged: (value) {
                      _presenter.form.value.control('state').updateValue(value);
                      _presenter.form.value.control('city').updateValue('');
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CityDropdown(
                    stateUF:
                        (_presenter.form.value.control('state').value
                            as String?) ??
                        '',
                    value:
                        (_presenter.form.value.control('city').value
                            as String?) ??
                        '',
                    onChanged: (value) => _presenter.form.value
                        .control('city')
                        .updateValue(value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Raça',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {
                    for (final breed in _breeds) {
                      if (!_presenter.selectedBreeds.value.contains(breed)) {
                        _presenter.toggleBreed(breed);
                      }
                    }
                  },
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppThemeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppThemeColors.inputBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppThemeColors.inputBorder),
              ),
              child: TextField(
                controller: _breedSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar raças...',
                  hintStyle: TextStyle(
                    color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppThemeColors.textSecondary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Watch((BuildContext context) {
              final List<String> selected = _presenter.selectedBreeds.value;
              final String query = _breedSearchController.text
                  .trim()
                  .toLowerCase();
              final List<String> filteredBreeds = query.isEmpty
                  ? _breeds
                  : _breeds
                        .where((String b) => b.toLowerCase().contains(query))
                        .toList();

              return Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: filteredBreeds.map((String breed) {
                  final bool isSelected = selected.contains(breed);
                  return BreedChip(
                    label: breed,
                    selected: isSelected,
                    onTap: () => _presenter.toggleBreed(breed),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClear();
                      widget.onClose?.call();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppThemeColors.inputBorder),
                      foregroundColor: AppThemeColors.textSecondary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: !_presenter.canApply.value
                        ? null
                        : () {
                            widget.onApply(_presenter.toDto());
                            widget.onClose?.call();
                            Navigator.of(context).pop();
                          },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
