import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../services/notification_service.dart';

class ApiInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();
    _logger.d('----------------------------------------');
    _logger.d('🚀 PROVIDER API REQUEST [$timestamp]');
    _logger.d('Method:  ${options.method}');
    _logger.d('URL:     ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Payload: ${options.data}');
    }
    _logger.d('----------------------------------------');

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

    _logger.d('----------------------------------------');
    _logger.d('✅ PROVIDER API RESPONSE [$timestamp] - Duration: $duration');
    _logger
        .d('Status:  ${response.statusCode} ${response.statusMessage ?? ''}');
    _logger.d('URL:     ${response.requestOptions.uri}');
    _logger.d('Data:    ${response.data}');
    _logger.d('----------------------------------------');

    // Show success notification for successful API calls
    _showSuccessNotification(response);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}');
    _logger.e('Response: ${err.response?.data}');

    final exception = _mapDioExceptionToMessage(err);

    // Show error notification
    _showErrorNotification(err, exception);

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

  void _showSuccessNotification(Response response) {
    final method = response.requestOptions.method;
    final path = response.requestOptions.path;

    // Don't show notifications for GET requests (too noisy)
    if (method == 'GET') return;

    // Don't show notifications for login/register (they have their own UI feedback)
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/providers/register')) {
      return;
    }

    String message;
    switch (method) {
      case 'POST':
        if (path.contains('/register')) {
          message = 'Registration successful!';
        } else {
          message = 'Item created successfully!';
        }
        break;
      case 'PUT':
        message = 'Item updated successfully!';
        break;
      case 'DELETE':
        message = 'Item deleted successfully!';
        break;
      case 'PATCH':
        message = 'Item updated successfully!';
        break;
      default:
        message = 'Operation completed successfully!';
    }

    NotificationService.showSuccess(message);
  }

  void _showErrorNotification(DioException err, String errorMessage) {
    final path = err.requestOptions.path;

    // Don't show notifications for auth failures (they have their own UI feedback)
    if (path.contains('/auth/login') || path.contains('/auth/register')) {
      return;
    }

    // Show appropriate notification based on error type
    if (err.type == DioExceptionType.connectionError) {
      NotificationService.showError(
          'No internet connection. Please check your network and try again.');
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      NotificationService.showError('Request timeout. Please try again.');
    } else if (err.response?.statusCode == 401) {
      NotificationService.showWarning('Session expired. Please login again.');
    } else if (err.response?.statusCode == 403) {
      NotificationService.showWarning(
          'Access denied. You don\'t have permission to perform this action.');
    } else if (err.response?.statusCode == 404) {
      NotificationService.showWarning('The requested resource was not found.');
    } else if (err.response?.statusCode == 500) {
      NotificationService.showError('Server error. Please try again later.');
    } else {
      NotificationService.showError(errorMessage);
    }
  }
}
