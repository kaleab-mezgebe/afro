import '../network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  /// Get wallet balance
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _apiClient.get('/providers/wallet');
      return response.data;
    } catch (e) {
      print('Error getting wallet balance: $e');
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<dynamic>> getTransactions({
    int? page,
    int? limit,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.get(
        '/providers/transactions',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      print('Error getting transactions: $e');
      rethrow;
    }
  }

  /// Request withdrawal
  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String method,
    required Map<String, dynamic> accountDetails,
    String? notes,
  }) async {
    try {
      final data = {
        'amount': amount,
        'method': method,
        'accountDetails': accountDetails,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiClient.post('/providers/withdraw', data: data);
      return response.data;
    } catch (e) {
      print('Error requesting withdrawal: $e');
      rethrow;
    }
  }

  /// Get withdrawal history
  Future<List<dynamic>> getWithdrawals({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        '/providers/withdrawals',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      print('Error getting withdrawals: $e');
      rethrow;
    }
  }

  /// Get earnings analytics
  Future<Map<String, dynamic>> getEarnings({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) queryParams['period'] = period;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        '/providers/earnings',
        queryParameters: queryParams,
      );

      return response.data;
    } catch (e) {
      print('Error getting earnings: $e');
      rethrow;
    }
  }

  /// Get payment settings
  Future<Map<String, dynamic>> getPaymentSettings() async {
    try {
      final response = await _apiClient.get('/providers/payment-settings');
      return response.data;
    } catch (e) {
      print('Error getting payment settings: $e');
      rethrow;
    }
  }

  /// Update payment settings
  Future<Map<String, dynamic>> updatePaymentSettings({
    Map<String, dynamic>? bankAccount,
    Map<String, dynamic>? mobileMoneyAccount,
    String? preferredMethod,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (bankAccount != null) data['bankAccount'] = bankAccount;
      if (mobileMoneyAccount != null) {
        data['mobileMoneyAccount'] = mobileMoneyAccount;
      }
      if (preferredMethod != null) data['preferredMethod'] = preferredMethod;

      final response = await _apiClient.put(
        '/providers/payment-settings',
        data: data,
      );
      return response.data;
    } catch (e) {
      print('Error updating payment settings: $e');
      rethrow;
    }
  }

  /// Get payout schedule
  Future<Map<String, dynamic>> getPayoutSchedule() async {
    try {
      final response = await _apiClient.get('/providers/payout-schedule');
      return response.data;
    } catch (e) {
      print('Error getting payout schedule: $e');
      rethrow;
    }
  }

  /// Confirm cash payment received
  Future<Map<String, dynamic>> confirmCashPayment({
    required String appointmentId,
    required double amount,
  }) async {
    try {
      final data = {
        'appointmentId': appointmentId,
        'amount': amount,
      };

      final response = await _apiClient.post(
        '/providers/confirm-cash-payment',
        data: data,
      );
      return response.data;
    } catch (e) {
      print('Error confirming cash payment: $e');
      rethrow;
    }
  }
}
