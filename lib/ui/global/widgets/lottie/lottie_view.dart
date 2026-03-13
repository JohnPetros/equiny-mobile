import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import 'lottie_presenter.dart';

class LottieView extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final Alignment alignment;
  final LottieDelegates? delegates;
  final FrameRate? frameRate;

  const LottieView({
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.alignment = Alignment.center,
    this.delegates,
    this.frameRate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final LottiePresenter presenter = LottiePresenter(assetPath: assetPath);

    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        assetPath,
        decoder: presenter.decoder,
        fit: fit,
        repeat: repeat,
        alignment: alignment,
        delegates: delegates,
        frameRate: frameRate,
      ),
    );
  }
}
