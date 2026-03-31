import 'package:logger/logger.dart';
import '../network/api_client.dart';

class AppointmentService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AppointmentService(this._apiClient);

  // Get shop appointments
  Future<List<dynamic>> getShopAppointments(
    String shopId, {
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) {
        queryParams['date'] = date;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }

      final response = await _apiClient.get(
        '/providers/shops/$shopId/appointments',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

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
      _logger.e('Error getting shop appointments', error: e);
      rethrow;
    }
  }

  // Update appointment status
  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    String status, {
    String? notes,
  }) async {
    try {
      final data = {
        'status': status,
        if (notes != null) 'notes': notes,
      };
      final response = await _apiClient.put(
        '/providers/appointments/$appointmentId/status',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error updating appointment status', error: e);
      rethrow;
    }
  }

  // Create appointment
  Future<Map<String, dynamic>> createAppointment(
    String shopId,
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      final response = await _apiClient.post(
        '/providers/shops/$shopId/appointments',
        data: appointmentData,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error creating appointment', error: e);
      rethrow;
    }
  }
}
