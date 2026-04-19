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
      AppLogger.e('Error creating review: $e');
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

      // Unwrap { success, data: { reviews: [...] } }
      final raw = response.data;
      final inner = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;

      if (inner is List) return inner;
      if (inner is Map && inner.containsKey('reviews')) {
        return inner['reviews'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      AppLogger.e('Error getting barber reviews: $e');
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

      final data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('reviews')) {
        return data['reviews'] as List<dynamic>;
      }

      return [];
    } catch (e) {
      AppLogger.e('Error getting my reviews: $e');
      rethrow;
    }
  }

  /// Get review by ID
  Future<Map<String, dynamic>> getReview(String reviewId) async {
    try {
      final response = await _apiClient.get('/reviews/$reviewId');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('review')) {
          return data['review'] as Map<String, dynamic>;
        }
        return data;
      }

      return {};
    } catch (e) {
      AppLogger.e('Error getting review: $e');
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
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('review')) {
          return responseData['review'] as Map<String, dynamic>;
        }
        return responseData;
      }

      return {};
    } catch (e) {
      AppLogger.e('Error updating review: $e');
      rethrow;
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.delete('/reviews/$reviewId');
    } catch (e) {
      AppLogger.e('Error deleting review: $e');
      rethrow;
    }
  }
}
