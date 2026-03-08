import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Crashlytics service for error reporting and crash tracking
/// Integrates with Firebase Crashlytics
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final Logger _logger = Logger();

  /// Initialize crashlytics
  Future<void> initialize() async {
    try {
      // Enable crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _logger.d('Crashlytics initialized');
    } catch (e) {
      _logger.e('Error initializing crashlytics: $e');
    }
  }

  /// Log non-fatal error
  Future<void> logError({
    required dynamic error,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      _logger.d('Error logged to Crashlytics: $error');
    } catch (e) {
      _logger.e('Error logging to crashlytics: $e');
    }
  }

  /// Log custom message
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      _logger.d('Message logged to Crashlytics: $message');
    } catch (e) {
      _logger.e('Error logging message: $e');
    }
  }

  /// Set user identifier
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      _logger.d('User ID set in Crashlytics: $userId');
    } catch (e) {
      _logger.e('Error setting user ID: $e');
    }
  }

  /// Set custom key
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      _logger.d('Custom key set: $key = $value');
    } catch (e) {
      _logger.e('Error setting custom key: $e');
    }
  }

  /// Check if crashlytics is enabled
  Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      return _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      _logger.e('Error checking crashlytics status: $e');
      return false;
    }
  }
}
