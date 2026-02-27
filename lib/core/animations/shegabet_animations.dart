import 'package:flutter/material.dart';

class ShegabetAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  
  // Button Tap Animation
  static Widget buttonTapAnimation({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = fast,
    double scaleDown = 0.95,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          // Animate scale down then back up
          onTap();
        },
        onTapDown: (_) {
          // Scale down effect handled by parent animation controller
        },
        onTapUp: (_) {
          // Scale back up effect handled by parent animation controller
        },
        onTapCancel: () {
          // Scale back up effect handled by parent animation controller
        },
        child: child,
      ),
    );
  }
  
  // Page Transition Animation
  static Widget pageTransition({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    SlideDirection direction = SlideDirection.left,
  }) {
    const Offset beginOffset = Offset(1.0, 0.0);
    const Offset endOffset = Offset.zero;
    
    final slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: easeInOut,
    ));
    
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: easeInOut,
    ));
    
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
  
  // Card Hover/Press Animation
  static Widget cardAnimation({
    required Widget child,
    Duration duration = medium,
    double elevationIncrease = 8.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return AnimatedContainer(
          duration: duration,
          transform: Matrix4.identity()..scale(scale),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Shimmer Loading Effect
  static Widget shimmerLoading({
    required Widget child,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -1.0, end: 2.0),
      duration: duration,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(value * 3.14159),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Success Checkmark Animation
  static Widget successCheckmark({
    double size = 80.0,
    Color color = Colors.green,
    Duration duration = medium,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: easeOut,
      builder: (context, progress, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: CheckmarkPainter(progress: progress, color: color),
        );
      },
    );
  }
  
  // Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = medium,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: easeInOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Scale In Animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = medium,
    double beginScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: beginScale, end: 1.0),
      duration: duration,
      curve: easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Slide In Animation
  static Widget slideIn({
    required Widget child,
    Duration duration = medium,
    SlideDirection direction = SlideDirection.up,
    double distance = 50.0,
  }) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.up:
        beginOffset = Offset(0, distance / 100);
        break;
      case SlideDirection.down:
        beginOffset = Offset(0, -distance / 100);
        break;
      case SlideDirection.left:
        beginOffset = Offset(distance / 100, 0);
        break;
      case SlideDirection.right:
        beginOffset = Offset(-distance / 100, 0);
        break;
    }
    
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: easeOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * 100, offset.dy * 100),
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Staggered Animation for Lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = medium,
    SlideDirection direction = SlideDirection.up,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: itemDuration,
          curve: easeOut,
          builder: (context, progress, child) {
            return Transform.translate(
              offset: Offset(
                0,
                (1 - progress) * 30 * (direction == SlideDirection.up ? 1 : -1),
              ),
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

enum SlideDirection {
  up,
  down,
  left,
  right,
}

// Custom Checkmark Painter for Success Animation
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  CheckmarkPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final checkmarkSize = size.width * 0.6;
    
    // Draw checkmark path
    final path = Path();
    
    if (progress > 0) {
      // First line of checkmark
      final firstLineProgress = (progress * 2).clamp(0.0, 1.0);
      final firstLineEnd = Offset(
        center.dx - checkmarkSize * 0.3 + (checkmarkSize * 0.15 * firstLineProgress),
        center.dy + (checkmarkSize * 0.1 * firstLineProgress),
      );
      
      path.moveTo(center.dx - checkmarkSize * 0.3, center.dy);
      path.lineTo(firstLineEnd.dx, firstLineEnd.dy);
    }
    
    if (progress > 0.5) {
      // Second line of checkmark
      final secondLineProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
      final secondLineStart = Offset(
        center.dx - checkmarkSize * 0.15,
        center.dy + checkmarkSize * 0.1,
      );
      final secondLineEnd = Offset(
        center.dx - checkmarkSize * 0.15 + (checkmarkSize * 0.45 * secondLineProgress),
        center.dy + checkmarkSize * 0.1 - (checkmarkSize * 0.45 * secondLineProgress),
      );
      
      path.moveTo(secondLineStart.dx, secondLineStart.dy);
      path.lineTo(secondLineEnd.dx, secondLineEnd.dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom Page Transition Builder
class ShegabetPageTransition extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ShegabetAnimations.pageTransition(
      child: child,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
    );
  }
}

// Animated Button with Tap Effect
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration? duration;
  final double? scaleDown;
  
  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.duration,
    this.scaleDown,
  }) : super(key: key);
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? ShegabetAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown ?? 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            style: widget.style,
            onPressed: widget.onPressed != null
                ? () {
                    _controller.forward().then((_) {
                      _controller.reverse();
                    });
                    widget.onPressed!();
                  }
                : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Animated Card with Hover Effect
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;
  final Duration? duration;
  final double? elevationIncrease;
  
  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.decoration,
    this.duration,
    this.elevationIncrease,
  }) : super(key: key);
  
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? ShegabetAnimations.medium,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.elevationIncrease ?? 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20 + _elevationAnimation.value,
                  offset: Offset(0, 8 + _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
