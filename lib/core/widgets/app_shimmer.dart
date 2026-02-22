import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/brand_colors.dart';

/// Loading skeleton — replaces the web app's `<Suspense fallback={<PageLoader />}>`.
class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? BrandColors.darkSurface : Colors.grey.shade200,
      highlightColor: isDark ? BrandColors.darkBorder : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Card-shaped shimmer for list loading states.
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmer(height: 120, borderRadius: 8),
            const SizedBox(height: 12),
            const AppShimmer(width: 180, height: 18),
            const SizedBox(height: 8),
            AppShimmer(width: MediaQuery.of(context).size.width * 0.6, height: 14),
          ],
        ),
      ),
    );
  }
}
