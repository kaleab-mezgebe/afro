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
      return response.data as List<dynamic>;
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
