import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'api_interceptor.dart';
import '../config/api_config.dart';
import '../services/cache_service.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  final CacheService _cacheService = CacheService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());
  }

  // Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

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
          _logger.d('Cache hit for: $path');
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
        _logger.d('Cached response for: $path');
      }

      return response;
    } catch (e) {
      _logger.e('GET request failed: $path', error: e);
      rethrow;
    }
  }

  String _generateCacheKey(String path, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return path;
    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final paramString =
        sortedParams.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$paramString';
  }

  /// Clear all cached data
  void clearCache() {
    _cacheService.clear();
    _logger.d('API cache cleared');
  }

  /// Clear specific cache entry
  void clearCacheEntry(String path, [Map<String, dynamic>? params]) {
    final cacheKey = _generateCacheKey(path, params);
    _cacheService.remove(cacheKey);
    _logger.d('Cache entry cleared: $cacheKey');
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
      _logger.e('POST request failed: $path', error: e);
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
      _logger.e('PUT request failed: $path', error: e);
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
      _logger.e('DELETE request failed: $path', error: e);
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
      _logger.e('PATCH request failed: $path', error: e);
      rethrow;
    }
  }
}
