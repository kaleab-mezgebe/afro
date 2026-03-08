import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/analytics_service.dart';
import '../services/crashlytics_service.dart';
import '../network/api_client.dart';

/// Core service providers for dependency injection

// Cache Service Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Crashlytics Service Provider
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  final service = CrashlyticsService();
  service.initialize();
  return service;
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Online Status Provider (from ConnectivityService)
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnlineStream;
});
