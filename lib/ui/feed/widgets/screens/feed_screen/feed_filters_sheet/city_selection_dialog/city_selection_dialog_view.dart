import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CitySelectionDialogView extends StatefulWidget {
  final List<String> cities;
  final String selectedCity;

  const CitySelectionDialogView({
    required this.cities,
    required this.selectedCity,
    super.key,
  });

  @override
  State<CitySelectionDialogView> createState() => _CitySelectionDialogViewState();
}

class _CitySelectionDialogViewState extends State<CitySelectionDialogView> {
  late List<String> _filteredCities;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = widget.cities.where((city) {
        return city.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeColors.surface,
      title: const Text('Selecione a Cidade'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar cidade...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: _filteredCities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('Nenhuma cidade encontrada'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        final cityName = _filteredCities[index];
                        final isSelected = cityName == widget.selectedCity;
                        return ListTile(
                          title: Text(cityName),
                          selected: isSelected,
                          selectedColor: AppThemeColors.primary,
                          selectedTileColor: AppThemeColors.primary.withValues(alpha: 0.1),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: AppThemeColors.primary)
                              : null,
                          onTap: () => Navigator.of(context).pop(cityName),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (widget.selectedCity.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('Limpar'),
          ),
      ],
    );
  }
}
