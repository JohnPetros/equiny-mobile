import 'package:equiny/ui/global/widgets/lottie/index.dart' as global_lottie;
import 'package:flutter/material.dart';

class ConfettiOverlayView extends StatelessWidget {
  const ConfettiOverlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Opacity(
          opacity: 0.85,
          child: global_lottie.Lottie(
            assetPath: 'assets/lotties/confetti.lottie',
            fit: BoxFit.cover,
            repeat: false,
          ),
        ),
      ),
    );
  }
}
