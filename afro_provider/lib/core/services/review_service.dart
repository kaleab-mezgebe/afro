import 'package:logger/logger.dart';
import '../network/api_client.dart';

class ReviewService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ReviewService(this._apiClient);

  // Get all reviews
  Future<List<dynamic>> getReviews() async {
    try {
      final response = await _apiClient.get('/providers/reviews');
      final responseData = response.data;
      
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('reviews')) {
          return responseData['reviews'] as List<dynamic>;
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
      _logger.e('Error getting reviews', error: e);
      rethrow;
    }
  }

  // Get review by ID
  Future<Map<String, dynamic>> getReview(String reviewId) async {
    try {
      final response = await _apiClient.get('/providers/reviews/$reviewId');
      return response.data;
    } catch (e) {
      _logger.e('Error getting review', error: e);
      rethrow;
    }
  }

  // Create review
  Future<Map<String, dynamic>> createReview(Map<String, dynamic> reviewData) async {
    try {
      final response = await _apiClient.post('/providers/reviews', data: reviewData);
      return response.data;
    } catch (e) {
      _logger.e('Error creating review', error: e);
      rethrow;
    }
  }

  // Update review
  Future<Map<String, dynamic>> updateReview(String reviewId, Map<String, dynamic> reviewData) async {
    try {
      final response = await _apiClient.put('/providers/reviews/$reviewId', data: reviewData);
      return response.data;
    } catch (e) {
      _logger.e('Error updating review', error: e);
      rethrow;
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.delete('/providers/reviews/$reviewId');
    } catch (e) {
      _logger.e('Error deleting review', error: e);
      rethrow;
    }
  }

  // Update review status
  Future<Map<String, dynamic>> updateReviewStatus(String reviewId, String status) async {
    try {
      final response = await _apiClient.patch('/providers/reviews/$reviewId/status', data: {'status': status});
      return response.data;
    } catch (e) {
      _logger.e('Error updating review status', error: e);
      rethrow;
    }
  }

  // Respond to review
  Future<Map<String, dynamic>> respondToReview(String reviewId, Map<String, dynamic> responseData) async {
    try {
      final response = await _apiClient.post('/providers/reviews/$reviewId/respond', data: responseData);
      return response.data;
    } catch (e) {
      _logger.e('Error responding to review', error: e);
      rethrow;
    }
  }

  // Get review statistics
  Future<Map<String, dynamic>> getReviewStats({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      queryParams['period'] = period;

      final response = await _apiClient.get(
        '/providers/reviews/stats',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error getting review stats', error: e);
      rethrow;
    }
  }

  // Export reviews
  Future<List<dynamic>> exportReviews({
    String? startDate,
    String? endDate,
    String? status,
    String? rating,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (status != null) queryParams['status'] = status;
      if (rating != null) queryParams['rating'] = rating;

      final response = await _apiClient.get(
        '/providers/reviews/export',
        queryParameters: queryParams,
      );
      final responseData = response.data;
      
      // Handle different response formats
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('reviews')) {
          return responseData['reviews'] as List<dynamic>;
        } else {
          return [];
        }
      } else if (responseData is List<dynamic>) {
        return responseData;
      } else {
        return [];
      }
    } catch (e) {
      _logger.e('Error exporting reviews', error: e);
      rethrow;
    }
  }
}
