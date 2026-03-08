import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class ServiceApiService {
  final EnhancedApiClient _apiClient;

  ServiceApiService(this._apiClient);

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

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting services: $e');
      rethrow;
    }
  }

  /// Get services by category
  Future<List<dynamic>> getServicesByCategory(String category) async {
    try {
      final response = await _apiClient.get('/services/category/$category');
      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting services by category: $e');
      rethrow;
    }
  }

  /// Get service by ID
  Future<Map<String, dynamic>> getService(String serviceId) async {
    try {
      final response = await _apiClient.get('/services/$serviceId');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting service: $e');
      rethrow;
    }
  }
}
