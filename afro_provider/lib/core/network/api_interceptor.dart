import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('API Request: ${options.method} ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      'API Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    _logger.d('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}');
    _logger.e('Response: ${err.response?.data}');

    final exception = _mapDioExceptionToMessage(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _mapDioExceptionToMessage(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final message =
            dioException.response?.data?['message'] ?? 'Unknown error';

        switch (statusCode) {
          case 400:
            return 'Bad request: $message';
          case 401:
            return 'Unauthorized. Please login again.';
          case 403:
            return 'Access forbidden. You don\'t have permission.';
          case 404:
            return 'Resource not found.';
          case 500:
            return 'Internal server error. Please try again later.';
          default:
            return 'HTTP Error $statusCode: $message';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.unknown:
        return dioException.message ?? 'Unknown network error occurred.';

      default:
        return dioException.message ?? 'Unexpected error occurred.';
    }
  }
}
