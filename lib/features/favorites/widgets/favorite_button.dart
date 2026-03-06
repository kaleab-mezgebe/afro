import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';

class FavoriteButton extends GetView<FavoritesController> {
  final Map<String, dynamic> provider;

  const FavoriteButton({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final providerId = provider['id']?.toString();
    
    return Obx(() {
      final isFavorited = providerId != null && controller.isFavorited(providerId);
      
      return InkWell(
        onTap: () => controller.toggleFavorite(provider),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isFavorited ? Colors.red.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFavorited ? Colors.red : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.grey.shade600,
            size: 20,
          ),
        ),
      );
    });
  }
}
