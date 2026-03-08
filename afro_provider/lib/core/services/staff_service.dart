import 'package:logger/logger.dart';
import '../network/api_client.dart';

class StaffService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  StaffService(this._apiClient);

  // Get shop staff
  Future<List<dynamic>> getShopStaff(String shopId) async {
    try {
      final response = await _apiClient.get('/providers/shops/$shopId/staff');
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Error getting shop staff', error: e);
      rethrow;
    }
  }

  // Create staff member
  Future<Map<String, dynamic>> createStaff(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/providers/shops/$shopId/staff',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error creating staff', error: e);
      rethrow;
    }
  }

  // Update staff member
  Future<Map<String, dynamic>> updateStaff(
    String staffId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/providers/staff/$staffId',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error updating staff', error: e);
      rethrow;
    }
  }

  // Delete staff member
  Future<void> deleteStaff(String staffId) async {
    try {
      await _apiClient.delete('/providers/staff/$staffId');
    } catch (e) {
      _logger.e('Error deleting staff', error: e);
      rethrow;
    }
  }
}
