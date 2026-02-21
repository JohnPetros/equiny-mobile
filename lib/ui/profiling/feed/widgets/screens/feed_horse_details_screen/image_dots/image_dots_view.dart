import 'package:flutter/material.dart';

class ImageDotsView extends StatelessWidget {
  final int count;
  final int currentIndex;

  const ImageDotsView({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == currentIndex;
        return Container(
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
