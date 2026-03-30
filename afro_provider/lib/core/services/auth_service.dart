import 'package:logger/logger.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AuthService(this._apiClient);

  // Development mode: Set mock JWT token
  Future<void> setMockAuthToken() async {
    // For development when backend is not available
    const mockJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJkZXZAZXhhbXBsZS5jb20iLCJuYW1lIjoiRGV2ZWxvcGVyIiwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImlhdCI6MTY5MDU4NzYwMH0.mock-signature';
    _apiClient.setAuthToken(mockJwt);
    _logger.i('Mock JWT token set for development');
  }

  // Verify token with backend
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-token',
        data: {'token': token},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error verifying token', error: e);
      rethrow;
    }
  }

  // Get current user info from backend
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return response.data;
    } catch (e) {
      _logger.e('Error getting current user', error: e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _apiClient.clearAuthToken();
    } catch (e) {
      _logger.e('Error signing out', error: e);
      rethrow;
    }
  }
}
