import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Shop data model
class Shop {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String email;
  final double rating;
  final bool isActive;
  final String? logoUrl;
  final String? description;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.rating,
    required this.isActive,
    this.logoUrl,
    this.description,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      logoUrl: json['logoUrl'],
      description: json['description'],
    );
  }
}

class ShopsNotifier extends StateNotifier<AsyncValue<List<Shop>>> {
  final ApiService _apiService = ApiService();

  ShopsNotifier() : super(const AsyncValue.loading()) {
    loadShops();
  }

  Future<void> loadShops() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getShops();
      final List<dynamic> data = response.data['data'] ?? response.data ?? [];
      
      final shops = data.map((json) => Shop.fromJson(json)).toList();
      state = AsyncValue.data(shops);
    } catch (e) {
      print('Error loading shops: $e');
      // Return empty list if API fails
      state = const AsyncValue.data([]);
    }
  }

  Future<void> addShop(Map<String, dynamic> shopData) async {
    try {
      await _apiService.createShop(shopData);
      await loadShops(); // Reload shops list
    } catch (e) {
      print('Error adding shop: $e');
      rethrow;
    }
  }

  Future<void> updateShop(String shopId, Map<String, dynamic> shopData) async {
    try {
      await _apiService.updateShop(shopId, shopData);
      await loadShops(); // Reload shops list
    } catch (e) {
      print('Error updating shop: $e');
      rethrow;
    }
  }

  Future<void> deleteShop(String shopId) async {
    try {
      await _apiService.deleteShop(shopId);
      await loadShops(); // Reload shops list
    } catch (e) {
      print('Error deleting shop: $e');
      rethrow;
    }
  }
}

final shopsProvider = StateNotifierProvider<ShopsNotifier, AsyncValue<List<Shop>>>((ref) {
  return ShopsNotifier();
});
