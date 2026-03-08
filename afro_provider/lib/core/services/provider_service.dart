import 'package:logger/logger.dart';
import '../network/api_client.dart';

class ProviderService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ProviderService(this._apiClient);

  // Get provider profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('/providers/profile');
      return response.data;
    } catch (e) {
      _logger.e('Error getting provider profile', error: e);
      rethrow;
    }
  }

  // Register new provider
  Future<Map<String, dynamic>> registerProvider(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post('/providers/register', data: data);
      return response.data;
    } catch (e) {
      _logger.e('Error registering provider', error: e);
      rethrow;
    }
  }

  // Update provider profile
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put('/providers/profile', data: data);
      return response.data;
    } catch (e) {
      _logger.e('Error updating provider profile', error: e);
      rethrow;
    }
  }
}
