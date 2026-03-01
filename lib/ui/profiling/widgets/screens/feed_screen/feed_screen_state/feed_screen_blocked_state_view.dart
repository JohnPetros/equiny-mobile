import 'package:flutter/material.dart';

class FeedScreenBlockedStateView extends StatelessWidget {
  final String message;
  final VoidCallback onGoToProfile;

  const FeedScreenBlockedStateView({
    required this.message,
    required this.onGoToProfile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onGoToProfile,
            child: const Text('Ir para perfil'),
          ),
        ],
      ),
    );
  }
}
