import 'package:logger/logger.dart';
import '../network/api_client.dart';

/// API service for fetching analytics data from backend
class AnalyticsApiService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AnalyticsApiService(this._apiClient);

  /// Get shop analytics
  Future<Map<String, dynamic>> getShopAnalytics(
    String shopId, {
    String period = 'today',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/$shopId/analytics',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting shop analytics: $e');
      rethrow;
    }
  }

  /// Get provider analytics
  Future<Map<String, dynamic>> getProviderAnalytics({
    String period = 'today',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/analytics',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting provider analytics: $e');
      rethrow;
    }
  }

  /// Get earnings summary
  Future<Map<String, dynamic>> getEarningsSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiClient.get(
        '/providers/earnings',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting earnings summary: $e');
      rethrow;
    }
  }

  /// Get appointment statistics
  Future<Map<String, dynamic>> getAppointmentStats({
    String period = 'week',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/appointments/stats',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting appointment stats: $e');
      rethrow;
    }
  }

  /// Get service performance
  Future<List<dynamic>> getServicePerformance(String shopId) async {
    try {
      final response = await _apiClient.get(
        '/providers/$shopId/services/performance',
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting service performance: $e');
      rethrow;
    }
  }

  /// Get customer insights
  Future<Map<String, dynamic>> getCustomerInsights(String shopId) async {
    try {
      final response = await _apiClient.get(
        '/providers/$shopId/customers/insights',
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting customer insights: $e');
      rethrow;
    }
  }

  /// Get revenue trends
  Future<List<dynamic>> getRevenueTrends({
    String period = 'month',
  }) async {
    try {
      final response = await _apiClient.get(
        '/providers/revenue/trends',
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting revenue trends: $e');
      rethrow;
    }
  }
}
