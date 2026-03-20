import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();
    AppLogger.d('----------------------------------------');
    AppLogger.d('🚀 API REQUEST [$timestamp]');
    AppLogger.d('Method:  ${options.method}');
    AppLogger.d('URL:     ${options.uri}');
    AppLogger.d('Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.d('Payload: ${options.data}');
    }
    AppLogger.d('----------------------------------------');
    
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();
    final startTime = response.requestOptions.extra['startTime'] as int?;
    final duration = startTime != null 
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms' 
        : 'unknown';

    AppLogger.d('----------------------------------------');
    AppLogger.d('✅ API RESPONSE [$timestamp] - Duration: $duration');
    AppLogger.d('Status:  ${response.statusCode} ${response.statusMessage ?? ''}');
    AppLogger.d('URL:     ${response.requestOptions.uri}');
    AppLogger.d('Data:    ${response.data}');
    AppLogger.d('----------------------------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('API Error: ${err.message}');
    AppLogger.e('Response: ${err.response?.data}');

    final exception = _mapDioExceptionToAppException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppException _mapDioExceptionToAppException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Request timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final message =
            dioException.response?.data?['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            return ValidationException(message);
          case 401:
            return const AuthenticationException(
              'Unauthorized. Please login again.',
            );
          case 403:
            return const AuthorizationException(
              'Access forbidden. You don\'t have permission.',
            );
          case 404:
            return const NotFoundException('Resource not found.');
          case 500:
            return const ServerException(
              'Internal server error. Please try again later.',
            );
          default:
            return ServerException('HTTP Error $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.unknown:
        return UnknownException(
          dioException.message ?? 'Unknown network error occurred.',
        );

      default:
        return UnknownException(
          dioException.message ?? 'Unexpected error occurred.',
        );
    }
  }
}
