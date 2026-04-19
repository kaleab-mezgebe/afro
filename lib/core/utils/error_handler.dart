import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
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
            'Cannot reach the server. Make sure your device and PC are on the same Wi-Fi network.';
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
        message =
            'Cannot connect to server. Check that the backend is running and your device is on the same network.';
        showBackendUnreachableSnackbar();
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
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.9),
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

  /// Show no internet snackbar with settings action
  static void showNoInternetSnackbar() {
    Get.snackbar(
      'No Internet',
      'Please check your internet connection',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.9),
      colorText: Get.theme.colorScheme.onError,
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          // Open device settings
          _openNetworkSettings();
        },
        child: Text(
          'Settings',
          style: TextStyle(color: Get.theme.colorScheme.onError),
        ),
      ),
    );
  }

  /// Show backend unreachable snackbar (different from no internet)
  static void showBackendUnreachableSnackbar() {
    Get.snackbar(
      'Server Unreachable',
      'Make sure your phone and PC are on the same Wi-Fi network.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.9),
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// Open device network settings
  static void _openNetworkSettings() {
    try {
      // Open device WiFi settings
      AppSettings.openAppSettings(type: AppSettingsType.wifi);
    } catch (e) {
      AppLogger.e('Error opening network settings: $e');
      // Fallback to showing instructions dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Network Settings'),
          content: const Text(
            'Please go to your device settings and check your internet connection:\n\n'
            '• Turn WiFi off and on\n'
            '• Check mobile data\n'
            '• Restart your router\n'
            '• Contact your network provider',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    }
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

  /// Handle any error and show appropriate snackbar
  static void handleError(dynamic error, {VoidCallback? onRetry}) {
    if (isNetworkError(error)) {
      // Show no internet snackbar for network errors
      showNoInternetSnackbar();
    } else {
      // Show regular error snackbar for other errors
      final message = getErrorMessage(error);
      showErrorSnackbar(message, onRetry: onRetry);
    }
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
