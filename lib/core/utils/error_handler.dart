import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'logger.dart';

/// Comprehensive error handling utility
/// Provides user-friendly error messages and retry logic
class ErrorHandler {
  /// Handle DioException and return user-friendly message
  static String handleDioError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message =
            'Connection timeout. Please check your internet connection and try again.';
        break;

      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;

      case DioExceptionType.receiveTimeout:
        message =
            'Server is taking too long to respond. Please try again later.';
        break;

      case DioExceptionType.badCertificate:
        message = 'Security certificate error. Please contact support.';
        break;

      case DioExceptionType.badResponse:
        message = _handleStatusCode(error.response?.statusCode);
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network settings.';
        break;

      case DioExceptionType.unknown:
        message = 'An unexpected error occurred. Please try again.';
        break;
    }

    AppLogger.e('DioError: ${error.type} - $message');
    return message;
  }

  /// Handle HTTP status codes
  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication failed. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found. Please try again later.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return 'Conflict. This resource already exists or is in use.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'An error occurred (Code: $statusCode). Please try again.';
    }
  }

  /// Show error snackbar with retry option
  static void showErrorSnackbar(
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
      mainButton: onRetry != null
          ? TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(color: Get.theme.colorScheme.onError),
              ),
            )
          : null,
    );
  }

  /// Handle error with automatic retry logic
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool exponentialBackoff = true,
  }) async {
    int attempt = 0;
    Duration currentDelay = retryDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          AppLogger.e('Max retries ($maxRetries) reached for operation');
          rethrow;
        }

        AppLogger.w(
          'Retry attempt $attempt/$maxRetries after ${currentDelay.inSeconds}s',
        );
        await Future.delayed(currentDelay);

        if (exponentialBackoff) {
          currentDelay *= 2;
        }
      }
    }
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    return false;
  }

  /// Check if error requires authentication
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401 ||
          error.response?.statusCode == 403;
    }
    return false;
  }

  /// Get error message from any exception
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    } else if (error is String) {
      return error;
    } else {
      return error.toString();
    }
  }
}
