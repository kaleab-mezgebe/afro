import 'package:flutter/material.dart';
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

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final favoritesList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      
      favorites.assignAll(favoritesList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> provider) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .add({
            ...provider,
            'createdAt': FieldValue.serverTimestamp(),
          });

      favorites.add({
        'id': docRef.id,
        ...provider,
      });

      Get.snackbar(
        'Added to Favorites',
        '${provider['name']} has been added to your favorites',
        snackPosition: SnackPosition.BOTTOM,
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

  bool isFavorited(String providerId) {
    return favorites.any((fav) => (fav['id']?.toString() == providerId) || (fav['providerId']?.toString() == providerId));
  }

  Future<void> toggleFavorite(Map<String, dynamic> provider) async {
    final providerId = provider['id']?.toString();
    if (providerId == null) return;

    if (isFavorited(providerId)) {
      final favorite = favorites.firstWhere((fav) => (fav['id']?.toString() == providerId) || (fav['providerId']?.toString() == providerId));
      await removeFromFavorites(favorite['id']);
    } else {
      await addToFavorites(provider);
    }
  }
}
