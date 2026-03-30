import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/provider_models.dart';
import '../../../../core/di/injection_container.dart';

// Shop State
class ShopState {
  final bool isLoading;
  final String? error;
  final List<Shop> shops;

  const ShopState({this.isLoading = false, this.error, this.shops = const []});

  ShopState copyWith({bool? isLoading, String? error, List<Shop>? shops}) {
    return ShopState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      shops: shops ?? this.shops,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          error == other.error &&
          shops == other.shops;

  @override
  int get hashCode => Object.hash(isLoading, error, shops);
}

// Shop Notifier
class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier() : super(const ShopState());

  Future<void> loadShops() async {
    state = const ShopState(isLoading: true);

    try {
      // Use the global shopService from injection_container.dart
      final response = await shopService.getShops();

      // Convert API response to Shop models
      final shops = response.map((json) {
        return Shop(
          id: json['id'].toString(),
          providerId: json['providerId']?.toString() ?? '',
          name: json['name'] ?? '',
          category: _parseCategory(json['category']),
          rating: (json['rating'] ?? 0).toDouble(),
          totalReviews: json['totalReviews'] ?? 0,
          isActive: json['isActive'] ?? true,
          createdAt: DateTime.parse(
              json['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(
              json['updatedAt'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();

      state = ShopState(
        isLoading: false,
        shops: shops,
        error: null,
      );
    } catch (e) {
      state = ShopState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createShop(Shop shop) async {
    try {
      state = state.copyWith(isLoading: true);

      final shopData = {
        'name': shop.name,
        'category': shop.category.value,
        'isActive': shop.isActive,
        'providerId': shop.providerId,
      };

      await shopService.createShop(shopData);
      await loadShops(); // Reload shops after creation
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create shop: ${e.toString()}',
      );
    }
  }

  Future<void> updateShop(Shop shop) async {
    try {
      state = state.copyWith(isLoading: true);

      final shopData = {
        'name': shop.name,
        'category': shop.category.value,
        'isActive': shop.isActive,
      };

      await shopService.updateShop(shop.id, shopData);
      await loadShops(); // Reload shops after update
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update shop: ${e.toString()}',
      );
    }
  }

  Future<void> deleteShop(String shopId) async {
    try {
      state = state.copyWith(isLoading: true);
      await shopService.deleteShop(shopId);
      await loadShops(); // Reload shops after deletion
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete shop: ${e.toString()}',
      );
    }
  }

  ShopCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'barbershop':
      case 'barber_shop':
        return ShopCategory.barberShop;
      case 'hairsalon':
      case 'hair_salon':
        return ShopCategory.hairSalon;
      case 'beautysalon':
      case 'beauty_salon':
        return ShopCategory.beautySalon;
      case 'makeupstudio':
      case 'makeup_studio':
        return ShopCategory.makeupStudio;
      case 'nailstudio':
      case 'nail_studio':
        return ShopCategory.nailStudio;
      default:
        return ShopCategory.barberShop;
    }
  }

  void addShop(Shop shop) {
    final currentShops = List<Shop>.from(state.shops);
    currentShops.add(shop);
    state = state.copyWith(shops: currentShops);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>(
  (ref) => ShopNotifier(),
);
