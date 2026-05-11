import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Dashboard data model
class DashboardStats {
  final int totalShops;
  final int activeShops;
  final int services;
  final int staff;
  final int customers;
  final double revenue;

  DashboardStats({
    required this.totalShops,
    required this.activeShops,
    required this.services,
    required this.staff,
    required this.customers,
    required this.revenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalShops: json['totalShops'] ?? 0,
      activeShops: json['activeShops'] ?? 0,
      services: json['services'] ?? 0,
      staff: json['staff'] ?? 0,
      customers: json['customers'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class DashboardActivity {
  final String title;
  final String subtitle;
  final String type;
  final DateTime createdAt;

  DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
  });
}

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final ApiService _apiService = ApiService();

  DashboardNotifier() : super(const AsyncValue.loading()) {
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getAnalytics();
      final data = response.data['data'] ?? response.data;

      final stats = DashboardStats(
        totalShops: data['totalShops'] ?? 0,
        activeShops: data['activeShops'] ?? 0,
        services: data['services'] ?? 0,
        staff: data['staff'] ?? 0,
        customers: data['customers'] ?? 0,
        revenue: (data['revenue'] ?? 0).toDouble(),
      );

      state = AsyncValue.data(stats);
    } catch (e) {
      print('Error loading dashboard stats: $e');
      // Return default stats if API fails
      state = AsyncValue.data(DashboardStats(
        totalShops: 0,
        activeShops: 0,
        services: 0,
        staff: 0,
        customers: 0,
        revenue: 0.0,
      ));
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  return DashboardNotifier();
});
