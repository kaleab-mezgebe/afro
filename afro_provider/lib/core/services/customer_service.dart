import 'package:logger/logger.dart';
import '../network/api_client.dart';

class CustomerService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  CustomerService(this._apiClient);

  // Get shop customers
  Future<List<dynamic>> getShopCustomers(String shopId) async {
    try {
      final response =
          await _apiClient.get('/providers/shops/$shopId/customers');

      // Handle different response formats
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['customers'] != null && data['customers'] is List) {
          return data['customers'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          return data['data'] as List<dynamic>;
        } else {
          // Return empty list if no customers found
          return [];
        }
      } else if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Error getting shop customers', error: e);
      rethrow;
    }
  }

  // Get customer details
  Future<Map<String, dynamic>> getCustomer(String customerId) async {
    try {
      final response = await _apiClient.get('/providers/customers/$customerId');
      return response.data;
    } catch (e) {
      _logger.e('Error getting customer', error: e);
      rethrow;
    }
  }

  // Get customer appointment history
  Future<List<dynamic>> getCustomerAppointments(String customerId) async {
    try {
      final response =
          await _apiClient.get('/providers/customers/$customerId/appointments');

      // Handle different response formats
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['appointments'] != null && data['appointments'] is List) {
          return data['appointments'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          return data['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else if (response.data is List) {
        return response.data as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Error getting customer appointments', error: e);
      rethrow;
    }
  }
}
