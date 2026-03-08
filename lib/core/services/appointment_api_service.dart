import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class AppointmentApiService {
  final EnhancedApiClient _apiClient;

  AppointmentApiService(this._apiClient);

  /// Create new appointment
  Future<Map<String, dynamic>> createAppointment({
    required String barberId,
    required String serviceId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      final data = {
        'barberId': barberId,
        'serviceType': serviceId,
        'appointmentDate': appointmentDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

      final response = await _apiClient.post('/appointments', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error creating appointment', error: e);
      rethrow;
    }
  }

  /// Get user's appointments
  Future<List<dynamic>> getMyAppointments({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/appointments/my',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting my appointments', error: e);
      rethrow;
    }
  }

  /// Get appointment by ID
  Future<Map<String, dynamic>> getAppointment(String appointmentId) async {
    try {
      final response = await _apiClient.get('/appointments/$appointmentId');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting appointment', error: e);
      rethrow;
    }
  }

  /// Cancel appointment
  Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    try {
      final data = {if (reason != null) 'reason': reason};

      final response = await _apiClient.post(
        '/appointments/$appointmentId/cancel',
        data: data,
      );
      return response.data;
    } catch (e) {
      AppLogger.e('Error cancelling appointment', error: e);
      rethrow;
    }
  }

  /// Reschedule appointment
  Future<Map<String, dynamic>> rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
  ) async {
    try {
      final data = {'appointmentDate': newDate.toIso8601String()};

      final response = await _apiClient.put(
        '/appointments/$appointmentId',
        data: data,
      );
      return response.data;
    } catch (e) {
      AppLogger.e('Error rescheduling appointment', error: e);
      rethrow;
    }
  }
}
