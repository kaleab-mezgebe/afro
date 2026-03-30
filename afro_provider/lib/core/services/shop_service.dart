import 'package:logger/logger.dart';
import '../network/api_client.dart';

class ShopService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ShopService(this._apiClient);

  // Get all provider shops
  Future<List<dynamic>> getShops() async {
    try {
      final response = await _apiClient.get('/providers/shops');

      // Handle different response formats
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check if shops are in a 'shops' field or 'data' field
        if (data['shops'] != null && data['shops'] is List) {
          return data['shops'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          return data['data'] as List<dynamic>;
        } else {
          // If it's a single shop object, wrap it in a list
          return [data];
        }
      } else if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        // Fallback: return empty list
        _logger.w('Unexpected response format: ${response.data.runtimeType}');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting shops', error: e);
      rethrow;
    }
  }

  // Create new shop
  Future<Map<String, dynamic>> createShop(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/providers/shops', data: data);
      return response.data;
    } catch (e) {
      _logger.e('Error creating shop', error: e);
      rethrow;
    }
  }

  // Update shop
  Future<Map<String, dynamic>> updateShop(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/providers/shops/$shopId',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error updating shop', error: e);
      rethrow;
    }
  }

  // Delete shop
  Future<void> deleteShop(String shopId) async {
    try {
      await _apiClient.delete('/providers/shops/$shopId');
    } catch (e) {
      _logger.e('Error deleting shop', error: e);
      rethrow;
    }
  }
}
