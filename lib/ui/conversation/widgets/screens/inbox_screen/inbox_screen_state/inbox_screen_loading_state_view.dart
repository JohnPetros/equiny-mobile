import 'package:flutter/material.dart';

class InboxScreenLoadingStateView extends StatelessWidget {
  const InboxScreenLoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
