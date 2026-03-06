import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InboxHeaderView extends StatelessWidget {
  final String title;
  final int unreadCount;

  const InboxHeaderView({
    required this.title,
    required this.unreadCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: AppFontSize.xxxl,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
