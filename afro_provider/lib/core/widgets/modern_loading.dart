import 'package:flutter/material.dart';
import '../utils/modern_theme.dart';
import 'modern_card.dart';

class ModernLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ModernLoadingSpinner({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.primary,
        ),
      ),
    );
  }
}

class ModernSkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ModernSkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20.0,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor ?? context.surfaceVariant,
            highlightColor ?? context.outline.withOpacity(0.3),
            baseColor ?? context.surfaceVariant,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showAvatar;
  final bool showTitle;
  final bool showSubtitle;
  final int lineCount;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.showAvatar = true,
    this.showTitle = true,
    this.showSubtitle = true,
    this.lineCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      width: width,
      height: height,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar) ...[
            Row(
              children: [
                ModernSkeletonLoader(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showTitle) ...[
                        ModernSkeletonLoader(
                          height: 16,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (showSubtitle)
                        ModernSkeletonLoader(
                          height: 12,
                          width: 150,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          ...List.generate(
            lineCount,
            (index) => Padding(
              padding:
                  EdgeInsets.only(bottom: index < lineCount - 1 ? 8.0 : 0.0),
              child: ModernSkeletonLoader(
                height: 14,
                width: index == lineCount - 1 ? 200 : double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final double displacement;

  const ModernPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.displacement = 40.0,
  });

  @override
  State<ModernPullToRefresh> createState() => _ModernPullToRefreshState();
}

class _ModernPullToRefreshState extends State<ModernPullToRefresh>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      displacement: widget.displacement,
      color: widget.color ?? context.primary,
      backgroundColor: context.surface,
      child: widget.child,
    );
  }
}

class ModernProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final String? label;

  const ModernProgressIndicator({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? context.surfaceVariant,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: valueColor ?? context.primary,
                borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModernLoadingSpinner(size: 32),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
