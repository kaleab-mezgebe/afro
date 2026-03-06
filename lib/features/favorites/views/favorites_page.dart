import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_widget.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/favorite_card.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: LoadingWidget())
            : controller.favorites.isEmpty
            ? _buildEmptyState()
            : _buildFavoritesList(),
      ),
      floatingActionButton: Obx(
        () => controller.favorites.isNotEmpty,
        child: FloatingActionButton(
          onPressed: controller.refreshFavorites,
          backgroundColor: AppTheme.primaryYellow,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: AppTheme.grey300),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your favorite service providers to see them here!',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.favorites.length,
        itemBuilder: (context, index) {
          final favorite = controller.favorites[index];
          return FavoriteCard(
            favorite: favorite,
            onTap: () => controller.navigateToProvider(favorite),
            onRemove: () => controller.removeFromFavorites(favorite.id),
          );
        },
      ),
    );
  }
}
