import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';

/// Analytics service for tracking user behavior and app events
/// Integrates with Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      AppLogger.d('Screen view logged: $screenName');
    } catch (e) {
      AppLogger.e('Error logging screen view: $e');
    }
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      AppLogger.d('Event logged: $name');
    } catch (e) {
      AppLogger.e('Error logging event: $e');
    }
  }

  /// Log search
  Future<void> logSearch({required String searchTerm, String? category}) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: category != null ? {'category': category} : null,
      );
      AppLogger.d('Search logged: $searchTerm');
    } catch (e) {
      AppLogger.e('Error logging search: $e');
    }
  }

  /// Log appointment booking
  Future<void> logBooking({
    required String barberId,
    required String serviceId,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'booking_created',
        parameters: {
          'barber_id': barberId,
          'service_id': serviceId,
          'price': price,
        },
      );
      AppLogger.d('Booking logged');
    } catch (e) {
      AppLogger.e('Error logging booking: $e');
    }
  }

  /// Log appointment cancellation
  Future<void> logCancellation({
    required String appointmentId,
    required String reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'booking_cancelled',
        parameters: {'appointment_id': appointmentId, 'reason': reason},
      );
      AppLogger.d('Cancellation logged');
    } catch (e) {
      AppLogger.e('Error logging cancellation: $e');
    }
  }

  /// Log payment
  Future<void> logPayment({
    required String paymentMethod,
    required double amount,
    required String currency,
    required String appointmentId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'payment_completed',
        parameters: {
          'payment_method': paymentMethod,
          'amount': amount,
          'currency': currency,
          'appointment_id': appointmentId,
        },
      );
      AppLogger.d('Payment logged');
    } catch (e) {
      AppLogger.e('Error logging payment: $e');
    }
  }

  /// Log review submission
  Future<void> logReview({
    required String barberId,
    required double rating,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'review_submitted',
        parameters: {'barber_id': barberId, 'rating': rating},
      );
      AppLogger.d('Review logged');
    } catch (e) {
      AppLogger.e('Error logging review: $e');
    }
  }

  /// Log favorite action
  Future<void> logFavorite({
    required String barberId,
    required bool isFavorite,
  }) async {
    try {
      await _analytics.logEvent(
        name: isFavorite ? 'favorite_added' : 'favorite_removed',
        parameters: {'barber_id': barberId},
      );
      AppLogger.d('Favorite logged');
    } catch (e) {
      AppLogger.e('Error logging favorite: $e');
    }
  }

  /// Log user sign up
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      AppLogger.d('Sign up logged: $method');
    } catch (e) {
      AppLogger.e('Error logging sign up: $e');
    }
  }

  /// Log user login
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      AppLogger.d('Login logged: $method');
    } catch (e) {
      AppLogger.e('Error logging login: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      AppLogger.d('User ID set: $userId');
    } catch (e) {
      AppLogger.e('Error setting user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      AppLogger.d('User property set: $name = $value');
    } catch (e) {
      AppLogger.e('Error setting user property: $e');
    }
  }

  /// Log app open
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      AppLogger.d('App open logged');
    } catch (e) {
      AppLogger.e('Error logging app open: $e');
    }
  }

  /// Log error
  Future<void> logError({
    required String error,
    String? stackTrace,
    bool fatal = false,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error': error,
          'stack_trace': stackTrace ?? 'N/A',
          'fatal': fatal,
        },
      );
      AppLogger.d('Error logged: $error');
    } catch (e) {
      AppLogger.e('Error logging error: $e');
    }
  }
}
