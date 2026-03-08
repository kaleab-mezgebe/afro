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
      return response.data as List<dynamic>;
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
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Error getting customer appointments', error: e);
      rethrow;
    }
  }
}
