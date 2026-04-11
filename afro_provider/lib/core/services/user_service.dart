import 'package:logger/logger.dart';
import '../network/api_client.dart';

class UserService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  UserService(this._apiClient);

  // Get all users
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _apiClient.get('/providers/users');
      final responseData = response.data;
      
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('users')) {
          return responseData['users'] as List<dynamic>;
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
      _logger.e('Error getting users', error: e);
      rethrow;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await _apiClient.get('/providers/users/$userId');
      return response.data;
    } catch (e) {
      _logger.e('Error getting user', error: e);
      rethrow;
    }
  }

  // Create user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/providers/users', data: userData);
      return response.data;
    } catch (e) {
      _logger.e('Error creating user', error: e);
      rethrow;
    }
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put('/providers/users/$userId', data: userData);
      return response.data;
    } catch (e) {
      _logger.e('Error updating user', error: e);
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _apiClient.delete('/providers/users/$userId');
    } catch (e) {
      _logger.e('Error deleting user', error: e);
      rethrow;
    }
  }

  // Update user status
  Future<Map<String, dynamic>> updateUserStatus(String userId, String status) async {
    try {
      final response = await _apiClient.patch('/providers/users/$userId/status', data: {'status': status});
      return response.data;
    } catch (e) {
      _logger.e('Error updating user status', error: e);
      rethrow;
    }
  }

  // Get user roles
  Future<List<dynamic>> getUserRoles() async {
    try {
      final response = await _apiClient.get('/providers/users/roles');
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('roles')) {
          return responseData['roles'] as List<dynamic>;
        } else if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else if (responseData is List<dynamic>) {
        return responseData;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Error getting user roles', error: e);
      rethrow;
    }
  }
}
