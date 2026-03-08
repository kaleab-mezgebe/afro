import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class ReviewApiService {
  final EnhancedApiClient _apiClient;

  ReviewApiService(this._apiClient);

  /// Create review
  Future<Map<String, dynamic>> createReview({
    required String barberId,
    String? appointmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      final data = {
        'barberId': barberId,
        if (appointmentId != null) 'appointmentId': appointmentId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      };

      final response = await _apiClient.post('/reviews', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error creating review', error: e);
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

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting barber reviews', error: e);
      rethrow;
    }
  }

  /// Get my reviews
  Future<List<dynamic>> getMyReviews({int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/reviews/my',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting my reviews', error: e);
      rethrow;
    }
  }

  /// Get review by ID
  Future<Map<String, dynamic>> getReview(String reviewId) async {
    try {
      final response = await _apiClient.get('/reviews/$reviewId');
      return response.data;
    } catch (e) {
      AppLogger.e('Error getting review', error: e);
      rethrow;
    }
  }

  /// Update review
  Future<Map<String, dynamic>> updateReview(
    String reviewId, {
    int? rating,
    String? comment,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (comment != null) data['comment'] = comment;

      final response = await _apiClient.put('/reviews/$reviewId', data: data);
      return response.data;
    } catch (e) {
      AppLogger.e('Error updating review', error: e);
      rethrow;
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.delete('/reviews/$reviewId');
    } catch (e) {
      AppLogger.e('Error deleting review', error: e);
      rethrow;
    }
  }
}
