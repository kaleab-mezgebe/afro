import 'package:logger/logger.dart';
import '../network/api_client.dart';

class AnalyticsService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AnalyticsService(this._apiClient);

  // Get shop analytics
  Future<Map<String, dynamic>> getShopAnalytics(
    String shopId, {
    String period = 'month',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/shops/$shopId/analytics',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting shop analytics', error: e);
      rethrow;
    }
  }

  // Get shop earnings
  Future<Map<String, dynamic>> getShopEarnings(
    String shopId, {
    String period = 'month',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/shops/$shopId/earnings',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting shop earnings', error: e);
      rethrow;
    }
  }

  // Get shop portfolio
  Future<Map<String, dynamic>> getShopPortfolio(String shopId) async {
    try {
      final response = await _apiClient.get(
        '/providers/shops/$shopId/portfolio',
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting shop portfolio', error: e);
      rethrow;
    }
  }

  // Get shop customers (CRM)
  Future<List<dynamic>> getShopCustomers(String shopId) async {
    try {
      final response = await _apiClient.get(
        '/providers/shops/$shopId/customers',
      );
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Error getting shop customers', error: e);
      rethrow;
    }
  }
}
