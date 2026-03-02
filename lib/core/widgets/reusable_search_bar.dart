import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReusableSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final EdgeInsets padding;

  const ReusableSearchBar({
    super.key,
    this.hintText = 'Search salons, services...',
    this.onSearchChanged,
    this.onFilterPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                onChanged: onSearchChanged ?? (query) {},
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(Icons.tune, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
