import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class CustomerApiService {
  final EnhancedApiClient _apiClient;

  CustomerApiService(this._apiClient);

  /// Get customer profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('/customers/profile');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting customer profile: $e');
      rethrow;
    }
  }

  /// Update customer profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    String? hairType,
    String? skinType,
    List<String>? preferredServices,
    Map<String, dynamic>? notificationPreferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;
      if (bio != null) data['bio'] = bio;
      if (gender != null) data['gender'] = gender;
      if (dateOfBirth != null)
        data['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (hairType != null) data['hairType'] = hairType;
      if (skinType != null) data['skinType'] = skinType;
      if (preferredServices != null)
        data['preferredServices'] = preferredServices;
      if (notificationPreferences != null)
        data['notificationPreferences'] = notificationPreferences;

      final response = await _apiClient.put('/customers/profile', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error updating customer profile: $e');
      rethrow;
    }
  }

  /// Get customer preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _apiClient.get('/customers/preferences');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting preferences: $e');
      rethrow;
    }
  }

  /// Update customer preferences
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final response = await _apiClient.put(
        '/customers/preferences',
        data: preferences,
      );
      return response.data;
    } catch (e) {
      AppLogger.e('Error updating preferences: $e');
      rethrow;
    }
  }
}
