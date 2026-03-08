import '../utils/logger.dart';
import 'enhanced_api_client.dart';

enum PaymentMethod {
  cash,
  card,
  stripe,
  paypal,
  flutterwave,
  chapa,
  telebirr,
  cbeBirr,
  mPesa,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

class PaymentApiService {
  final EnhancedApiClient _apiClient;

  PaymentApiService(this._apiClient);

  /// Initialize payment
  Future<Map<String, dynamic>> initializePayment({
    required String appointmentId,
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'ETB',
    String? returnUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'appointmentId': appointmentId,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod.name,
        if (returnUrl != null) 'returnUrl': returnUrl,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _apiClient.post(
        '/payments/initialize',
        data: data,
      );
      return response.data;
    } catch (e) {
      AppLogger.e('Error initializing payment: $e');
      rethrow;
    }
  }

  /// Verify payment
  Future<Map<String, dynamic>> verifyPayment({
    required String transactionId,
    String? paymentGateway,
  }) async {
    try {
      final data = {
        'transactionId': transactionId,
        if (paymentGateway != null) 'paymentGateway': paymentGateway,
      };

      final response = await _apiClient.post('/payments/verify', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error verifying payment: $e');
      rethrow;
    }
  }

  /// Get available payment methods
  Future<List<dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('/payments/methods');
      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting payment methods: $e');
      rethrow;
    }
  }

  /// Get payment history
  Future<List<dynamic>> getPaymentHistory({int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/payments/history',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting payment history: $e');
      rethrow;
    }
  }

  /// Get payment by ID
  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    try {
      final response = await _apiClient.get('/payments/$paymentId');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting payment: $e');
      rethrow;
    }
  }

  /// Request refund
  Future<Map<String, dynamic>> requestRefund({
    required String paymentId,
    required String reason,
    double? amount,
  }) async {
    try {
      final data = {
        'paymentId': paymentId,
        'reason': reason,
        if (amount != null) 'amount': amount,
      };

      final response = await _apiClient.post('/payments/refund', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error requesting refund: $e');
      rethrow;
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats() async {
    try {
      final response = await _apiClient.get('/payments/stats');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting payment stats: $e');
      rethrow;
    }
  }

  /// Process cash payment (mark as paid at barbershop)
  Future<Map<String, dynamic>> processCashPayment({
    required String paymentId,
  }) async {
    try {
      final response = await _apiClient.post('/payments/$paymentId/cash-paid');
      return response.data;
    } catch (e) {
      AppLogger.e('Error processing cash payment: $e');
      rethrow;
    }
  }

  /// Get payment receipt
  Future<Map<String, dynamic>> getPaymentReceipt(String paymentId) async {
    try {
      final response = await _apiClient.get('/payments/$paymentId/receipt');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting payment receipt: $e');
      rethrow;
    }
  }
}
