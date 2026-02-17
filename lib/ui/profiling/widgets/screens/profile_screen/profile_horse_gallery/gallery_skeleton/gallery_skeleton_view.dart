import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/gallery_skeleton/gallery_skeleton_shimmer/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GallerySkeletonView extends StatelessWidget {
  final int maxImages;

  const GallerySkeletonView({required this.maxImages, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List<Widget>.generate(maxImages, (int index) {
        return const _GallerySkeletonSlot();
      }),
    );
  }
}

class _GallerySkeletonSlot extends StatelessWidget {
  const _GallerySkeletonSlot();

  @override
  Widget build(BuildContext context) {
    return GallerySkeletonShimmer(
      child: Container(
        width: 104,
        height: 136,
        decoration: BoxDecoration(
          color: AppThemeColors.border,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppThemeColors.border.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
      ),
    );
  }
}
