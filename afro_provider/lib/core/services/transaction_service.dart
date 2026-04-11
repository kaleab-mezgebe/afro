import 'package:logger/logger.dart';
import '../network/api_client.dart';

class TransactionService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  TransactionService(this._apiClient);

  // Get all transactions
  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _apiClient.get('/providers/transactions');
      final responseData = response.data;
      
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('transactions')) {
          return responseData['transactions'] as List<dynamic>;
        } else {
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
      _logger.e('Error getting transactions', error: e);
      rethrow;
    }
  }

  // Get transaction by ID
  Future<Map<String, dynamic>> getTransaction(String transactionId) async {
    try {
      final response = await _apiClient.get('/providers/transactions/$transactionId');
      return response.data;
    } catch (e) {
      _logger.e('Error getting transaction', error: e);
      rethrow;
    }
  }

  // Create transaction
  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiClient.post('/providers/transactions', data: transactionData);
      return response.data;
    } catch (e) {
      _logger.e('Error creating transaction', error: e);
      rethrow;
    }
  }

  // Update transaction
  Future<Map<String, dynamic>> updateTransaction(String transactionId, Map<String, dynamic> transactionData) async {
    try {
      final response = await _apiClient.put('/providers/transactions/$transactionId', data: transactionData);
      return response.data;
    } catch (e) {
      _logger.e('Error updating transaction', error: e);
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _apiClient.delete('/providers/transactions/$transactionId');
    } catch (e) {
      _logger.e('Error deleting transaction', error: e);
      rethrow;
    }
  }

  // Refund transaction
  Future<Map<String, dynamic>> refundTransaction(String transactionId, Map<String, dynamic> refundData) async {
    try {
      final response = await _apiClient.post('/providers/transactions/$transactionId/refund', data: refundData);
      return response.data;
    } catch (e) {
      _logger.e('Error refunding transaction', error: e);
      rethrow;
    }
  }

  // Update transaction status
  Future<Map<String, dynamic>> updateTransactionStatus(String transactionId, String status) async {
    try {
      final response = await _apiClient.patch('/providers/transactions/$transactionId/status', data: {'status': status});
      return response.data;
    } catch (e) {
      _logger.e('Error updating transaction status', error: e);
      rethrow;
    }
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      queryParams['period'] = period;

      final response = await _apiClient.get(
        '/providers/transactions/stats',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting transaction stats', error: e);
      rethrow;
    }
  }

  // Get revenue summary
  Future<Map<String, dynamic>> getRevenueSummary({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      queryParams['period'] = period;

      final response = await _apiClient.get(
        '/providers/transactions/revenue',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting revenue summary', error: e);
      rethrow;
    }
  }

  // Export transactions
  Future<List<dynamic>> exportTransactions({
    String? startDate,
    String? endDate,
    String? status,
    String? customerId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;
      if (customerId != null) queryParams['customerId'] = customerId;

      final response = await _apiClient.get(
        '/providers/transactions/export',
        queryParameters: queryParams,
      );
      final responseData = response.data;
      
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('transactions')) {
          return responseData['transactions'] as List<dynamic>;
        } else {
          return [];
        }
      } else if (responseData is List<dynamic>) {
        return responseData;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Error exporting transactions', error: e);
      rethrow;
    }
  }
}
