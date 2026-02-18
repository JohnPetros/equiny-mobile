import 'package:flutter/material.dart';

class BottomActionButtonView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final double size;

  const BottomActionButtonView({
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.size = 72,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0B1018).withValues(alpha: 0.88),
          border: Border.all(color: const Color(0xFF273247)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.42, color: iconColor),
      ),
    );
  }
}
