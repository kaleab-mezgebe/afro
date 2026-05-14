import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

/// Modern skeleton loader for better UX during data loading
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ModernTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _buildShimmer(),
    );
  }

  Widget _buildShimmer() {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            ModernTheme.surfaceVariant,
            ModernTheme.surfaceVariant.withValues(alpha: 0.5),
            ModernTheme.surfaceVariant,
          ],
          stops: const [0.0, 0.5, 1.0],
          tileMode: TileMode.repeated,
        ).createShader(bounds);
      },
      child: ColoredBox(color: ModernTheme.surfaceVariant),
    );
  }
}

/// Skeleton card for list items
class SkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 200,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(height: 120, borderRadius: 16),
            SizedBox(height: 12),
            SkeletonLoader(height: 20, width: 120, borderRadius: 8),
            SizedBox(height: 8),
            SkeletonLoader(height: 14, width: 80, borderRadius: 6),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(height: 32, width: 100, borderRadius: 8),
                SkeletonLoader(height: 32, width: 32, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list for loading states
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: ModernTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SkeletonLoader(width: 56, height: 56, borderRadius: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonLoader(height: 20, width: 150, borderRadius: 8),
                        SizedBox(height: 8),
                        SkeletonLoader(height: 14, width: 100, borderRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton stats card for dashboard
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(height: 24, width: 24, borderRadius: 12),
          SizedBox(height: 12),
          SkeletonLoader(height: 32, width: 80, borderRadius: 8),
          SizedBox(height: 8),
          SkeletonLoader(height: 14, width: 60, borderRadius: 6),
        ],
      ),
    );
  }
}
