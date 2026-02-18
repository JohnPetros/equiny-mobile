import 'package:flutter/material.dart';

class FeedScreenEmptyStateView extends StatelessWidget {
  final VoidCallback onClearFilters;

  const FeedScreenEmptyStateView({
    required this.onClearFilters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Nao encontramos cavalos com esses filtros.'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onClearFilters,
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}
