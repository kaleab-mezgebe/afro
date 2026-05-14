import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        color: AppTheme.grey100,
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
          colors: [AppTheme.grey100, AppTheme.grey200, AppTheme.grey100],
          stops: const [0.0, 0.5, 1.0],
          tileMode: TileMode.repeated,
        ).createShader(bounds);
      },
      child: const ColoredBox(color: AppTheme.grey100),
    );
  }
}

/// Skeleton card for list items
class SkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const SkeletonCard({super.key, this.height = 200, this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
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

/// Skeleton grid for loading states
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double? height;

  const SkeletonGrid({super.key, this.itemCount = 6, this.height});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCard(height: height ?? 200);
      },
    );
  }
}

/// Skeleton list for loading states
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({super.key, this.itemCount = 5});

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
              color: Colors.white,
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
