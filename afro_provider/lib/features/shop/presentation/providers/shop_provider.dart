import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/provider_models.dart';

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock data
      final mockShops = [
        Shop(
          id: '1',
          providerId: 'provider_1',
          name: 'John\'s Barber Shop',
          category: ShopCategory.barberShop,
          rating: 4.5,
          totalReviews: 128,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Shop(
          id: '2',
          providerId: 'provider_1',
          name: 'Elegant Hair Salon',
          category: ShopCategory.hairSalon,
          rating: 4.8,
          totalReviews: 96,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      state = ShopState(isLoading: false, shops: mockShops);
    } catch (e) {
      state = ShopState(error: e.toString());
    }
  }

  void addShop(Shop shop) {
    final currentShops = List<Shop>.from(state.shops);
    currentShops.add(shop);
    state = state.copyWith(shops: currentShops);
  }

  void updateShop(Shop shop) {
    final currentShops = List<Shop>.from(state.shops);
    final index = currentShops.indexWhere((s) => s.id == shop.id);

    if (index != -1) {
      currentShops[index] = shop;
    }

    state = state.copyWith(shops: currentShops);
  }

  void deleteShop(String shopId) {
    final currentShops =
        state.shops.where((shop) => shop.id != shopId).toList();
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
