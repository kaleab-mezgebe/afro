import 'package:flutter/material.dart';

class FilterOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool isSelected;

  FilterOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.isSelected = false,
  });

  FilterOption copyWith({
    IconData? icon,
    String? title,
    String? subtitle,
    String? value,
    bool? isSelected,
  }) {
    return FilterOption(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
