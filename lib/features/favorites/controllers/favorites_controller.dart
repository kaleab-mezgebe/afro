import 'package:get/get.dart';

import '../../../core/services/favorite_api_service.dart';
import '../../../core/utils/error_handler.dart';
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
      ErrorHandler.handleError(e, onRetry: loadFavorites);
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
      ErrorHandler.showErrorSnackbar(
        '${provider['name'] ?? 'Provider'} added to favorites',
      );
    } catch (e) {
      ErrorHandler.handleError(e);
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
    } catch (e) {
      ErrorHandler.handleError(e);
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
