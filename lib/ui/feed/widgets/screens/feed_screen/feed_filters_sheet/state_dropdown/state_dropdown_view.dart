import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/feed/widgets/screens/feed_screen/feed_filters_sheet/state_selection_dialog/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateDropdownView extends ConsumerStatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const StateDropdownView({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  ConsumerState<StateDropdownView> createState() => _StateDropdownViewState();
}

class _StateDropdownViewState extends ConsumerState<StateDropdownView> {
  List<String>? _states;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final locationService = ref.read(locationServiceProvider);
    final response = await locationService.fetchStates();

    if (!mounted) return;

    if (response.isFailure) {
      setState(() {
        _isLoading = false;
        _error = response.errorMessage;
      });
      return;
    }

    setState(() {
      _states = response.body;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value.isNotEmpty;

    if (_isLoading) {
      return _buildLoadingDropdown();
    }

    if (_error != null) {
      return _buildErrorDropdown();
    }

    if (_states == null) {
      return _buildLoadingDropdown();
    }

    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) =>
              StateSelectionDialog(states: _states!, selectedUF: widget.value),
        );
        if (result != null) {
          widget.onChanged(result);
        }
      },
      child: _buildDropdownContainer(hasValue),
    );
  }

  Widget _buildDropdownContainer(bool hasValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppThemeColors.inputBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 18,
            color: hasValue
                ? AppThemeColors.primary
                : AppThemeColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasValue ? widget.value : 'Estado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: hasValue
                    ? AppThemeColors.textMain
                    : AppThemeColors.textSecondary.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppThemeColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppThemeColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_outlined,
            size: 18,
            color: AppThemeColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppThemeColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppThemeColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppThemeColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 18,
            color: Colors.red.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Erro ao carregar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
          ),
          Icon(
            Icons.error_outline,
            size: 18,
            color: Colors.red.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
