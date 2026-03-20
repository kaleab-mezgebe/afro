import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/favorite_api_service.dart';
import '../../../routes/app_routes.dart';

class FavoritesController extends GetxController {
  final FavoriteApiService _favoriteApiService;

  FavoritesController({required FavoriteApiService favoriteApiService})
    : _favoriteApiService = favoriteApiService;

  final RxList<Map<String, dynamic>> favorites = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final data = await _favoriteApiService.getFavorites();
      favorites.assignAll(data.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> provider) async {
    final barberId = provider['id']?.toString();
    if (barberId == null) return;
    try {
      await _favoriteApiService.addFavorite(barberId);
      await loadFavorites();
      Get.snackbar(
        'Added to Favorites',
        '${provider['name'] ?? 'Provider'} added to favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to favorites',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeFromFavorites(String barberId) async {
    try {
      await _favoriteApiService.removeFavorite(barberId);
      favorites.removeWhere(
        (fav) =>
            fav['id']?.toString() == barberId ||
            fav['barberId']?.toString() == barberId,
      );
      Get.snackbar(
        'Removed',
        'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from favorites',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  void navigateToProvider(Map<String, dynamic> provider) {
    Get.toNamed(AppRoutes.portfolio, arguments: provider);
  }

  bool isFavorited(String barberId) {
    return favorites.any(
      (fav) =>
          fav['id']?.toString() == barberId ||
          fav['barberId']?.toString() == barberId,
    );
  }

  Future<void> toggleFavorite(Map<String, dynamic> provider) async {
    final barberId = provider['id']?.toString();
    if (barberId == null) return;

    if (isFavorited(barberId)) {
      await removeFromFavorites(barberId);
    } else {
      await addToFavorites(provider);
    }
  }
}
