import 'package:flutter/material.dart';

class HomeCategory {
  final String name;
  final IconData icon;
  final String gender;
  final bool isSelected;

  HomeCategory({
    required this.name,
    required this.icon,
    required this.gender,
    this.isSelected = false,
  });

  HomeCategory copyWith({bool? isSelected}) {
    return HomeCategory(
      name: name,
      icon: icon,
      gender: gender,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
