import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class ServiceApiService {
  final EnhancedApiClient _apiClient;

  ServiceApiService(this._apiClient);

  /// Get services for a specific barber
  Future<List<dynamic>> getServicesByBarber(String barberId) async {
    try {
      final response = await _apiClient.get('/barbers/$barberId/services');
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('services'))
        return data['services'] as List;
      if (data is Map && data.containsKey('data')) return data['data'] as List;
      return [];
    } catch (e) {
      AppLogger.e('Error getting barber services: $e');
      rethrow;
    }
  }

  /// Get all services
  Future<List<dynamic>> getServices({
    String? category,
    String? genderTarget,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (genderTarget != null) queryParams['genderTarget'] = genderTarget;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/services',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('services')) {
        return data['services'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      AppLogger.e('Error getting services: $e');
      rethrow;
    }
  }

  /// Get services by category
  Future<List<dynamic>> getServicesByCategory(String category) async {
    try {
      final response = await _apiClient.get('/services/category/$category');
      final data = response.data;

      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('services')) {
        return data['services'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      AppLogger.e('Error getting services by category: $e');
      rethrow;
    }
  }

  /// Get service by ID
  Future<Map<String, dynamic>> getService(String serviceId) async {
    try {
      final response = await _apiClient.get('/services/$serviceId');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('service')) {
          return data['service'] as Map<String, dynamic>;
        }
        return data;
      }

      return {};
    } catch (e) {
      AppLogger.e('Error getting service: $e');
      rethrow;
    }
  }
}
