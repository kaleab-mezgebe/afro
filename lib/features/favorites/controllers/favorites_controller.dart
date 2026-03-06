import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/services/favorites_service.dart';
import '../../../routes/app_routes.dart';

class FavoritesController extends GetxController {
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
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        favorites.clear();
        isLoading.value = false;
        return;
      }

      final favoritesDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      if (favoritesDoc.exists) {
        final favoritesData = favoritesDoc.data() as Map<String, dynamic>?;
        final favoritesList = favoritesData?['favorites'] as List<dynamic>? ?? [];
        favorites.assignAll(favoritesList.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> provider) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            ...provider,
            'createdAt': FieldValue.serverTimestamp(),
          });

      Get.snackbar(
        'Added to Favorites',
        '${provider['name']} has been added to your favorites',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to favorites: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(favoriteId)
          .delete();

      favorites.removeWhere((fav) => fav['id'] == favoriteId);

      Get.snackbar(
        'Removed from Favorites',
        'Provider has been removed from your favorites',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from favorites: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  void navigateToProvider(Map<String, dynamic> provider) {
    // Navigate to provider details page
    // This can be expanded later to show provider details
    Get.snackbar(
      'Provider Details',
      'Navigating to ${provider['name']} details',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}
