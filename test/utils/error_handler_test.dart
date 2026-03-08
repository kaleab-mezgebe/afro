import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:customer_app/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('should handle connection timeout error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      // Act
      final message = ErrorHandler.handleDioError(error);

      // Assert
      expect(message, contains('Connection timeout'));
    });

    test('should handle connection error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      // Act
      final message = ErrorHandler.handleDioError(error);

      // Assert
      expect(message, contains('No internet connection'));
    });

    test('should handle 401 unauthorized error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // Act
      final message = ErrorHandler.handleDioError(error);

      // Assert
      expect(message, contains('Authentication failed'));
    });

    test('should handle 404 not found error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      // Act
      final message = ErrorHandler.handleDioError(error);

      // Assert
      expect(message, contains('not found'));
    });

    test('should handle 500 server error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      // Act
      final message = ErrorHandler.handleDioError(error);

      // Assert
      expect(message, contains('Server error'));
    });

    test('should detect network errors', () {
      // Arrange
      final networkError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final otherError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
      );

      // Act & Assert
      expect(ErrorHandler.isNetworkError(networkError), isTrue);
      expect(ErrorHandler.isNetworkError(otherError), isFalse);
    });

    test('should detect auth errors', () {
      // Arrange
      final authError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      final otherError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      // Act & Assert
      expect(ErrorHandler.isAuthError(authError), isTrue);
      expect(ErrorHandler.isAuthError(otherError), isFalse);
    });

    test('should get error message from string', () {
      // Act
      final message = ErrorHandler.getErrorMessage('Test error');

      // Assert
      expect(message, equals('Test error'));
    });

    test('should get error message from DioException', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      // Act
      final message = ErrorHandler.getErrorMessage(error);

      // Assert
      expect(message, contains('Connection timeout'));
    });

    test('should retry operation with success', () async {
      // Arrange
      int attempts = 0;
      Future<String> operation() async {
        attempts++;
        if (attempts < 2) {
          throw Exception('Temporary error');
        }
        return 'Success';
      }

      // Act
      final result = await ErrorHandler.withRetry(
        operation,
        maxRetries: 3,
        retryDelay: const Duration(milliseconds: 10),
      );

      // Assert
      expect(result, equals('Success'));
      expect(attempts, equals(2));
    });

    test('should fail after max retries', () async {
      // Arrange
      int attempts = 0;
      Future<String> operation() async {
        attempts++;
        throw Exception('Persistent error');
      }

      // Act & Assert
      expect(
        () => ErrorHandler.withRetry(
          operation,
          maxRetries: 3,
          retryDelay: const Duration(milliseconds: 10),
        ),
        throwsException,
      );
      expect(attempts, equals(3));
    });
  });
}
