import 'package:flutter/material.dart';
import '../utils/modern_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final VoidCallback? onTap;
  final bool showShadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.onTap,
    this.showShadow = true,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient != null ? null : (color ?? context.surface),
        gradient: gradient ?? ModernTheme.cardGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: boxShadow ?? (showShadow ? ModernTheme.softShadow : null),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: cardChild,
      );
    }

    return cardChild;
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: ModernTheme.glassDecoration(
        color: context.surface,
        blur: blur,
        opacity: opacity,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: cardChild,
      );
    }

    return cardChild;
  }
}

class InteractiveCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool enableScaleAnimation;
  final bool enableHoverEffect;

  const InteractiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.color,
    this.borderRadius,
    this.enableScaleAnimation = true,
    this.enableHoverEffect = true,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableScaleAnimation ? _scaleAnimation.value : 1.0,
          child: MouseRegion(
            onEnter: (_) {
              if (widget.enableHoverEffect) {
                setState(() => _isHovered = true);
              }
            },
            onExit: (_) {
              if (widget.enableHoverEffect) {
                setState(() => _isHovered = false);
              }
            },
            child: GestureDetector(
              onTapDown: (_) {
                if (widget.enableScaleAnimation) {
                  _animationController.forward();
                }
              },
              onTapUp: (_) {
                if (widget.enableScaleAnimation) {
                  _animationController.reverse();
                }
              },
              onTapCancel: () {
                if (widget.enableScaleAnimation) {
                  _animationController.reverse();
                }
              },
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height,
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color ?? context.surface,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        _isHovered ? 0.1 : 0.05,
                      ),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _elevationAnimation.value),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
