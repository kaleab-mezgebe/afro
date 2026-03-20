import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class AuthApiService {
  final EnhancedApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Verify Firebase token with backend
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-token',
        data: {'token': token},
      );
      return response.data;
    } catch (e) {
      AppLogger.e('Error verifying token: $e');
      rethrow;
    }
  }

  /// Get current user from backend
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting current user: $e');
      rethrow;
    }
  }

  /// Register new customer
  Future<Map<String, dynamic>> registerCustomer(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/auth/register/customer', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error registering customer: $e');
      rethrow;
    }
  }
}
