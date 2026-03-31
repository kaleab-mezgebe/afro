import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/modern_theme.dart';
import 'modern_responsive.dart';

class ModernBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool enableLabelAnimation;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.enableLabelAnimation = true,
  });

  @override
  State<ModernBottomNavigationBar> createState() =>
      _ModernBottomNavigationBarState();
}

class _ModernBottomNavigationBarState extends State<ModernBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index / widget.items.length,
          (index + 1) / widget.items.length,
          curve: Curves.easeOut,
        ),
      )),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveBreakpoints.isMobile(context) ? 60 : 70,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveBreakpoints.isMobile(context) ? 6 : 12,
            vertical: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onTap(index);
                  },
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.95 + (_animations[index].value * 0.05),
                        child: _NavigationItemWidget(
                          item: item,
                          isSelected: isSelected,
                          enableLabelAnimation: widget.enableLabelAnimation,
                          selectedItemColor: widget.selectedItemColor,
                          unselectedItemColor: widget.unselectedItemColor,
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationItemWidget extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final bool enableLabelAnimation;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const _NavigationItemWidget({
    required this.item,
    required this.isSelected,
    required this.enableLabelAnimation,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isMobile ? 4 : 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? (selectedItemColor ?? context.primary).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
            ),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? (selectedItemColor ?? context.primary)
                  : (unselectedItemColor ?? context.textTertiary),
              size: isMobile ? 16 : 18,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 0 : 1),
        Expanded(
          flex: 2,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isMobile ? (isSelected ? 7 : 6) : (isSelected ? 9 : 8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? (selectedItemColor ?? context.primary)
                  : (unselectedItemColor ?? context.textTertiary),
              letterSpacing: isSelected ? 0.02 : 0.01,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(item.label),
            ),
          ),
        ),
      ],
    );
  }
}

class ModernFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableAnimation;
  final String? tooltip;

  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.enableAnimation = true,
    this.tooltip,
  });

  @override
  State<ModernFloatingActionButton> createState() =>
      _ModernFloatingActionButtonState();
}

class _ModernFloatingActionButtonState extends State<ModernFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.easeInOut,
      ),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));

    if (widget.enableAnimation) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fab = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.enableAnimation ? _rotationAnimation.value : 0.0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? context.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ModernTheme.mediumShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onPressed();
                  },
                  child: Center(
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    return fab;
  }
}

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableBackButton;
  final VoidCallback? onBackPressed;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.enableBackButton = false,
    this.onBackPressed,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.surface,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (enableBackButton)
                ModernBackButton(
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(width: 40),
              Expanded(
                child: Text(
                  title,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: foregroundColor ?? context.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
              if (actions != null) ...actions! else const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

class ModernBackButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color? color;

  const ModernBackButton({
    super.key,
    required this.onPressed,
    this.color,
  });

  @override
  State<ModernBackButton> createState() => _ModernBackButtonState();
}

class _ModernBackButtonState extends State<ModernBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: widget.color ?? context.textPrimary,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? route;
  final Widget? badge;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.route,
    this.badge,
  });
}
