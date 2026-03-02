import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'filter_option.dart';

class ReusableFilterDialog extends StatelessWidget {
  final String title;
  final List<FilterOption>? filterOptions;
  final Function(Map<String, dynamic>)? onApplyFilters;

  const ReusableFilterDialog({
    super.key,
    this.title = 'Filter Options',
    this.filterOptions,
    this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context) {
    final options = filterOptions ?? [
      FilterOption(
        icon: Icons.location_on,
        title: 'Distance',
        subtitle: 'Within 5 km',
        value: 'distance',
      ),
      FilterOption(
        icon: Icons.star,
        title: 'Rating',
        subtitle: '4+ stars',
        value: 'rating',
      ),
      FilterOption(
        icon: Icons.attach_money,
        title: 'Price Range',
        subtitle: '\$25 - \$100',
        value: 'price',
      ),
    ];

    return AlertDialog(
      title: Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) => ListTile(
          leading: Icon(option.icon, color: AppTheme.textSecondary),
          title: Text(option.title, style: const TextStyle(color: AppTheme.textSecondary)),
          subtitle: Text(option.subtitle),
          onTap: () {
            // Handle filter selection
          },
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onApplyFilters?.call({});
          },
          child: const Text('Apply', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      ],
    );
  }

  static void show({
    required BuildContext context,
    String title = 'Filter Options',
    List<FilterOption>? filterOptions,
    Function(Map<String, dynamic>)? onApplyFilters,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReusableFilterDialog(
        title: title,
        filterOptions: filterOptions,
        onApplyFilters: onApplyFilters,
      ),
    );
  }
}
