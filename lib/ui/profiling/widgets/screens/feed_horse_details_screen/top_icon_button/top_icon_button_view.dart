import 'package:flutter/material.dart';

class TopIconButtonView extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const TopIconButtonView({required this.icon, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
