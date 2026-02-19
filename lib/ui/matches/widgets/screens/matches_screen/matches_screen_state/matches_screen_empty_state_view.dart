import 'package:flutter/material.dart';

class MatchesScreenEmptyStateView extends StatelessWidget {
  final VoidCallback onGoToFeed;

  const MatchesScreenEmptyStateView({
    required this.onGoToFeed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Voce ainda nao possui matches.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onGoToFeed,
              child: const Text('Ir para o Feed'),
            ),
          ],
        ),
      ),
    );
  }
}
