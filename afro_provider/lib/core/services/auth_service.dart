import 'package:logger/logger.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AuthService(this._apiClient);

  // Login with email and password - backend authentication
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Set the JWT token from response
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('token')) {
          _apiClient.setAuthToken(data['token'] as String);
          _logger.i('JWT token set from backend login');
        } else if (data.containsKey('accessToken')) {
          _apiClient.setAuthToken(data['accessToken'] as String);
          _logger.i('Access token set from backend login');
        }
      }

      return response.data;
    } catch (e) {
      _logger.e('Error logging in', error: e);
      rethrow;
    }
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
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Error signing out', error: e);
      rethrow;
    }
  }

  // Set authentication token (for cases where token is obtained elsewhere)
  void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
    _logger.i('Auth token set');
  }

  // Development mode: Set mock JWT token (kept for backward compatibility)
  Future<void> setMockAuthToken() async {
    // For development when backend is not available
    const mockJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJkZXZAZXhhbXBsZS5jb20iLCJuYW1lIjoiRGV2ZWxvcGVyIiwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImlhdCI6MTY5MDU4NzYwMH0.mock-signature';
    _apiClient.setAuthToken(mockJwt);
    _logger.w('Mock JWT token set for development only - not for production');
  }
}
