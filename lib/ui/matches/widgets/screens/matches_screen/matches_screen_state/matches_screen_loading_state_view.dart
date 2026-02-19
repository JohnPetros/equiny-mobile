import 'package:flutter/material.dart';

class MatchesScreenLoadingStateView extends StatelessWidget {
  const MatchesScreenLoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
