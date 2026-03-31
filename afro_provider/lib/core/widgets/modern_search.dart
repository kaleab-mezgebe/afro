import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/modern_theme.dart';
import 'modern_card.dart';

class ModernSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const ModernSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = true,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: widget.padding ?? EdgeInsets.zero,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search...',
          prefixIcon: widget.prefixIcon ??
              Icon(
                Icons.search,
                color: context.textSecondary,
                size: 20,
              ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.suffixIcon != null) widget.suffixIcon!,
              if (widget.showClearButton && _hasText) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _onClear,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.clear,
                      color: context.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: TextStyle(
            color: context.textSecondary,
            fontSize: 16,
          ),
        ),
        style: TextStyle(
          color: widget.textColor ?? context.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}

class ModernFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final EdgeInsets? padding;

  const ModernFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.padding,
  });

  @override
  State<ModernFilterChip> createState() => _ModernFilterChipState();
}

class _ModernFilterChipState extends State<ModernFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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
        widget.onSelected?.call(!widget.selected);
      },
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.selected
                    ? (widget.selectedColor ?? context.primary).withOpacity(0.1)
                    : (widget.unselectedColor ?? context.surfaceVariant),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.selected
                      ? (widget.selectedColor ?? context.primary)
                      : context.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.selected
                          ? (widget.selectedColor ?? context.primary)
                          : context.textSecondary,
                      fontSize: 14,
                      fontWeight:
                          widget.selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModernFilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? action;
  final EdgeInsets? padding;
  final bool initiallyExpanded;

  const ModernFilterSection({
    super.key,
    required this.title,
    required this.children,
    this.action,
    this.padding,
    this.initiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (action != null) ...[
            const Spacer(),
            action!,
          ],
        ],
      ),
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class ModernSortOption {
  final String label;
  final String value;
  final IconData? icon;

  const ModernSortOption({
    required this.label,
    required this.value,
    this.icon,
  });
}

class ModernSortDropdown extends StatelessWidget {
  final ModernSortOption? value;
  final List<ModernSortOption> options;
  final ValueChanged<ModernSortOption?>? onChanged;
  final String? hintText;
  final double? width;

  const ModernSortDropdown({
    super.key,
    this.value,
    required this.options,
    this.onChanged,
    this.hintText,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.outline,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ModernSortOption>(
          value: value,
          isExpanded: true,
          hint: Text(
            hintText ?? 'Sort by',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: context.textSecondary,
            size: 20,
          ),
          items: options.map((option) {
            return DropdownMenuItem<ModernSortOption>(
              value: option,
              child: Row(
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      color: context.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          selectedItemBuilder: value != null
              ? (context) {
                  return [
                    Row(
                      children: [
                        if (value!.icon != null) ...[
                          Icon(
                            value!.icon,
                            color: context.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            value!.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ];
                }
              : null,
        ),
      ),
    );
  }
}
