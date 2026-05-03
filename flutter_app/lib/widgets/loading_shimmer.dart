import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';

/// Skeleton loader matching card-heavy layouts (dashboard / list placeholders).
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.child,
    this.padding,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceContainerHighest.withValues(alpha: 0.6);
    final highlight = cs.surface.withValues(alpha: 0.85);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child ?? const DashboardSkeleton(),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(height: 88, radius: 22),
        const SizedBox(height: AppSpacing.betweenSections),
        _bar(height: 180, radius: 20),
        const SizedBox(height: AppSpacing.betweenSections),
        _bar(height: 120, radius: 20),
      ],
    );
  }

  Widget _bar({required double height, required double radius}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.betweenListItems),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
    );
  }
}
