import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConfettiOverlayView extends StatelessWidget {
  const ConfettiOverlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Opacity(
          opacity: 0.85,
          child: Lottie.asset(
            'assets/lotties/confetti.json',
            fit: BoxFit.cover,
            repeat: false,
          ),
        ),
      ),
    );
  }
}
