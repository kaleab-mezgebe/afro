import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class BarberApiService {
  final EnhancedApiClient _apiClient;

  BarberApiService(this._apiClient);

  /// Get all barbers with optional filters
  Future<List<dynamic>> getBarbers({
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lng'] = longitude;
      if (radius != null) queryParams['radius'] = radius;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/barbers',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('barbers')) {
        return data['barbers'] as List<dynamic>;
      } else if (data is Map && data.containsKey('data')) {
        return data['data'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      AppLogger.e('Error getting barbers: $e');
      rethrow;
    }
  }

  /// Get specific barber by ID
  Future<Map<String, dynamic>> getBarber(String barberId) async {
    try {
      final response = await _apiClient.get('/barbers/$barberId');
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('barber')) {
          return data['barber'] as Map<String, dynamic>;
        }
        return data;
      }
      
      return {};
    } catch (e) {
      AppLogger.e('Error getting barber: $e');
      rethrow;
    }
  }

  /// Get barber reviews
  Future<List<dynamic>> getBarberReviews(
    String barberId, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/reviews/barber/$barberId',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('reviews')) {
        return data['reviews'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      AppLogger.e('Error getting barber reviews: $e');
      rethrow;
    }
  }
}
