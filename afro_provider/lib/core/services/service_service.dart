import 'package:logger/logger.dart';
import '../network/api_client.dart';

class ServiceService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ServiceService(this._apiClient);

  // Get shop services
  Future<List<dynamic>> getShopServices(String shopId) async {
    try {
      final response =
          await _apiClient.get('/providers/shops/$shopId/services');
      final responseData = response.data;

      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else {
          // If it's a map but no 'data' field, return empty list or handle accordingly
          _logger.w('Unexpected response format: ${responseData.keys}');
          return [];
        }
      } else if (responseData is List<dynamic>) {
        return responseData;
      } else {
        _logger.e('Unexpected response type: ${responseData.runtimeType}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting shop services', error: e);
      rethrow;
    }
  }

  // Create service
  Future<Map<String, dynamic>> createService(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/providers/shops/$shopId/services',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error creating service', error: e);
      rethrow;
    }
  }

  // Update service
  Future<Map<String, dynamic>> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/providers/services/$serviceId',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error updating service', error: e);
      rethrow;
    }
  }

  // Delete service
  Future<void> deleteService(String serviceId) async {
    try {
      await _apiClient.delete('/providers/services/$serviceId');
    } catch (e) {
      _logger.e('Error deleting service', error: e);
      rethrow;
    }
  }
}
