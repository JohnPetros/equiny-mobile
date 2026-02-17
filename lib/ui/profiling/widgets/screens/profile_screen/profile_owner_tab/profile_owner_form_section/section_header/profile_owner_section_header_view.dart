import 'package:flutter/material.dart';

class ProfileOwnerSectionHeaderView extends StatelessWidget {
  final ThemeData theme;
  final String title;

  const ProfileOwnerSectionHeaderView({
    required this.theme,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF6E80A8),
        letterSpacing: 1.1,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
