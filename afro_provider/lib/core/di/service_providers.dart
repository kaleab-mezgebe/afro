import 'package:afro_provider/core/services/analytics_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/shop_service.dart';
import '../network/api_client.dart';

/// Core service providers for dependency injection

// API Client Provider (must be defined first as other services depend on it)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Cache Service Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Shop Service Provider
final shopServiceProvider = Provider<ShopService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShopService(apiClient);
});

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsApiService>((ref) {
  return AnalyticsApiService(ref.watch(apiClientProvider));
});

// Online Status Provider (from ConnectivityService)
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnlineStream;
});
