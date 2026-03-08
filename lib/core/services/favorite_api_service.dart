import '../utils/logger.dart';
import 'enhanced_api_client.dart';

class FavoriteApiService {
  final EnhancedApiClient _apiClient;

  FavoriteApiService(this._apiClient);

  /// Add barber to favorites
  Future<Map<String, dynamic>> addFavorite(String barberId) async {
    try {
      final response = await _apiClient.post('/favorites/barber/$barberId');
      return response.data;
    } catch (e) {
      AppLogger.e('Error adding favorite', error: e);
      rethrow;
    }
  }

  /// Remove barber from favorites
  Future<void> removeFavorite(String barberId) async {
    try {
      await _apiClient.delete('/favorites/barber/$barberId');
    } catch (e) {
      AppLogger.e('Error removing favorite', error: e);
      rethrow;
    }
  }

  /// Get user's favorite barbers
  Future<List<dynamic>> getFavorites({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        '/favorites',
        queryParameters: queryParams,
      );

      return response.data as List<dynamic>;
    } catch (e) {
      AppLogger.e('Error getting favorites', error: e);
      rethrow;
    }
  }

  /// Check if barber is favorited
  Future<bool> isFavorite(String barberId) async {
    try {
      final response = await _apiClient.get('/favorites/barber/$barberId/check');
      return response.data['isFavorite'] ?? false;
    } catch (e) {
      AppLogger.e('Error checking favorite', error: e);
      return false;
    }
  }
}
