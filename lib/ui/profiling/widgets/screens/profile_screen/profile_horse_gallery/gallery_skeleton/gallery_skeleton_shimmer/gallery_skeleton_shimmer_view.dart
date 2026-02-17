import 'dart:math' as math;

import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GallerySkeletonShimmerView extends StatefulWidget {
  final Widget child;

  const GallerySkeletonShimmerView({required this.child, super.key});

  @override
  State<GallerySkeletonShimmerView> createState() =>
      _GallerySkeletonShimmerViewState();
}

class _GallerySkeletonShimmerViewState extends State<GallerySkeletonShimmerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double value = _controller.value;

        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment(-1 + (value * 2), -0.2),
              end: Alignment(value * 2, 0.2),
              colors: <Color>[
                AppThemeColors.border.withValues(alpha: 0.45),
                AppThemeColors.textSecondary.withValues(alpha: 0.2),
                AppThemeColors.border.withValues(alpha: 0.45),
              ],
              stops: const <double>[0.2, 0.5, 0.8],
              transform: const _RotateGradientTransform(angle: math.pi / 12),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _RotateGradientTransform extends GradientTransform {
  final double angle;

  const _RotateGradientTransform({required this.angle});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()
      ..translateByDouble(bounds.width / 2, bounds.height / 2, 0, 1)
      ..rotateZ(angle)
      ..translateByDouble(-bounds.width / 2, -bounds.height / 2, 0, 1);
  }
}
