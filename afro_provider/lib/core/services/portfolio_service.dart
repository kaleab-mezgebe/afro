import 'package:logger/logger.dart';
import '../network/api_client.dart';

class PortfolioService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  PortfolioService(this._apiClient);

  // Get shop portfolio photos
  Future<List<dynamic>> getPortfolioPhotos(String shopId) async {
    try {
      final response =
          await _apiClient.get('/providers/shops/$shopId/portfolio');
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Error getting portfolio photos', error: e);
      rethrow;
    }
  }

  // Upload portfolio photo
  Future<Map<String, dynamic>> uploadPhoto(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/providers/shops/$shopId/portfolio',
        data: data,
      );
      return response.data;
    } catch (e) {
      _logger.e('Error uploading photo', error: e);
      rethrow;
    }
  }

  // Delete portfolio photo
  Future<void> deletePhoto(String photoId) async {
    try {
      await _apiClient.delete('/providers/portfolio/$photoId');
    } catch (e) {
      _logger.e('Error deleting photo', error: e);
      rethrow;
    }
  }

  // Get shop reviews
  Future<List<dynamic>> getShopReviews(String shopId) async {
    try {
      final response = await _apiClient.get('/providers/shops/$shopId/reviews');
      return response.data as List<dynamic>;
    } catch (e) {
      _logger.e('Error getting reviews', error: e);
      rethrow;
    }
  }

  // Reply to review
  Future<Map<String, dynamic>> replyToReview(
    String reviewId,
    String reply,
  ) async {
    try {
      final response = await _apiClient.post(
        '/providers/reviews/$reviewId/reply',
        data: {'reply': reply},
      );
      return response.data;
    } catch (e) {
      _logger.e('Error replying to review', error: e);
      rethrow;
    }
  }
}
