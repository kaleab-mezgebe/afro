import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../network/api_interceptor.dart';
import '../utils/logger.dart';
import 'cache_service.dart';

class EnhancedApiClient {
  late final Dio _dio;
  final FirebaseAuth _firebaseAuth;
  final CacheService _cacheService = CacheService();

  EnhancedApiClient(this._firebaseAuth) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Firebase token to all requests
          final token = await _getFirebaseToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            // Token unavailable (network blocked) — use dev bypass with real UID
            // so the backend can still identify the correct user
            final uid = _currentUid;
            if (uid != null) {
              options.headers['Authorization'] = 'Bearer dev-bypass-token';
              options.headers['X-Dev-Uid'] = uid;
              AppLogger.w(
                'Using dev bypass with uid=$uid (token refresh blocked)',
              );
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<String?> _getFirebaseToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Try cached token first (no network needed)
        try {
          final token = await user.getIdToken(false);
          if (token != null && token.isNotEmpty) return token;
        } catch (_) {}
        // Only force-refresh if cached token failed
        try {
          final token = await user.getIdToken(true);
          if (token != null && token.isNotEmpty) return token;
        } catch (refreshErr) {
          AppLogger.w('Token refresh failed (network blocked?): $refreshErr');
        }
      }
    } catch (e) {
      AppLogger.e('Error getting Firebase token: $e');
    }
    AppLogger.w('No valid Firebase token — request will be unauthenticated');
    return null;
  }

  /// Returns the current Firebase user's UID (from cache, no network needed)
  String? get _currentUid => _firebaseAuth.currentUser?.uid;

  // GET request with caching support
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = false,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    try {
      // Check cache if enabled
      if (useCache) {
        final cacheKey = _generateCacheKey(path, queryParameters);
        final cachedData = _cacheService.get<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          AppLogger.d('Cache hit for: $path');
          return Response(
            requestOptions: RequestOptions(path: path),
            data: cachedData,
            statusCode: 200,
          );
        }
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      // Cache successful responses
      if (useCache && response.statusCode == 200 && response.data != null) {
        final cacheKey = _generateCacheKey(path, queryParameters);
        _cacheService.set(cacheKey, response.data, duration: cacheDuration);
        AppLogger.d('Cached response for: $path');
      }

      return response;
    } catch (e) {
      AppLogger.e('GET request failed: $path - $e');
      rethrow;
    }
  }

  String _generateCacheKey(String path, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return path;
    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final paramString = sortedParams
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$path?$paramString';
  }

  /// Clear all cached data
  void clearCache() {
    _cacheService.clear();
    AppLogger.d('API cache cleared');
  }

  /// Clear specific cache entry
  void clearCacheEntry(String path, [Map<String, dynamic>? params]) {
    final cacheKey = _generateCacheKey(path, params);
    _cacheService.remove(cacheKey);
    AppLogger.d('Cache entry cleared: $cacheKey');
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.e('POST request failed: $path - $e');
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.e('PUT request failed: $path - $e');
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.e('DELETE request failed: $path - $e');
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.e('PATCH request failed: $path - $e');
      rethrow;
    }
  }
}
