import 'package:flutter/material.dart';

class MatchOptionItemView extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const MatchOptionItemView({
    required this.label,
    required this.onTap,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
