import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StateSelectionDialogView extends StatefulWidget {
  final List<String> states;
  final String selectedUF;

  const StateSelectionDialogView({
    required this.states,
    required this.selectedUF,
    super.key,
  });

  @override
  State<StateSelectionDialogView> createState() => _StateSelectionDialogViewState();
}

class _StateSelectionDialogViewState extends State<StateSelectionDialogView> {
  late List<String> _filteredStates;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStates = widget.states;
    _searchController.addListener(_filterStates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStates = widget.states.where((state) {
        return state.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemeColors.surface,
      title: const Text('Selecione o Estado'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar estado...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: _filteredStates.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('Nenhum estado encontrado'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredStates.length,
                      itemBuilder: (context, index) {
                        final stateUF = _filteredStates[index];
                        final isSelected = stateUF == widget.selectedUF;
                        return ListTile(
                          title: Text(stateUF),
                          selected: isSelected,
                          selectedColor: AppThemeColors.primary,
                          selectedTileColor: AppThemeColors.primary.withValues(alpha: 0.1),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: AppThemeColors.primary)
                              : null,
                          onTap: () => Navigator.of(context).pop(stateUF),
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
        if (widget.selectedUF.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('Limpar'),
          ),
      ],
    );
  }
}
