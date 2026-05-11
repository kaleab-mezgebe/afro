import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Service data model
class ServiceItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final int duration;
  final String description;
  final bool isActive;
  final String? imageUrl;

  ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    required this.description,
    required this.isActive,
    this.imageUrl,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 30,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
    );
  }
}

class ServicesNotifier extends StateNotifier<AsyncValue<List<ServiceItem>>> {
  final ApiService _apiService = ApiService();

  ServicesNotifier() : super(const AsyncValue.loading()) {
    loadServices();
  }

  Future<void> loadServices() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getServices();
      final List<dynamic> data = response.data['data'] ?? response.data ?? [];
      
      final services = data.map((json) => ServiceItem.fromJson(json)).toList();
      state = AsyncValue.data(services);
    } catch (e) {
      print('Error loading services: $e');
      // Return empty list if API fails
      state = const AsyncValue.data([]);
    }
  }

  Future<void> addService(Map<String, dynamic> serviceData) async {
    try {
      await _apiService.createService(serviceData);
      await loadServices(); // Reload services list
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      await _apiService.updateService(serviceId, serviceData);
      await loadServices(); // Reload services list
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _apiService.deleteService(serviceId);
      await loadServices(); // Reload services list
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }
}

final servicesProvider = StateNotifierProvider<ServicesNotifier, AsyncValue<List<ServiceItem>>>((ref) {
  return ServicesNotifier();
});
