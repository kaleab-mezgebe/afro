import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

/// Analytics service for tracking provider behavior and app events
/// Integrates with Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();

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
      _logger.d('Screen view logged: $screenName');
    } catch (e) {
      _logger.e('Error logging screen view: $e');
    }
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.d('Event logged: $name');
    } catch (e) {
      _logger.e('Error logging event: $e');
    }
  }

  /// Log appointment acceptance
  Future<void> logAppointmentAccepted({
    required String appointmentId,
    required String customerId,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'appointment_accepted',
        parameters: {
          'appointment_id': appointmentId,
          'customer_id': customerId,
          'price': price,
        },
      );
      _logger.d('Appointment acceptance logged');
    } catch (e) {
      _logger.e('Error logging appointment acceptance: $e');
    }
  }

  /// Log appointment completion
  Future<void> logAppointmentCompleted({
    required String appointmentId,
    required double earnings,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'appointment_completed',
        parameters: {
          'appointment_id': appointmentId,
          'earnings': earnings,
        },
      );
      _logger.d('Appointment completion logged');
    } catch (e) {
      _logger.e('Error logging appointment completion: $e');
    }
  }

  /// Log service creation
  Future<void> logServiceCreated({
    required String serviceId,
    required String serviceName,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'service_created',
        parameters: {
          'service_id': serviceId,
          'service_name': serviceName,
          'price': price,
        },
      );
      _logger.d('Service creation logged');
    } catch (e) {
      _logger.e('Error logging service creation: $e');
    }
  }

  /// Log earnings withdrawal
  Future<void> logWithdrawal({
    required double amount,
    required String method,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'earnings_withdrawal',
        parameters: {
          'amount': amount,
          'method': method,
        },
      );
      _logger.d('Withdrawal logged');
    } catch (e) {
      _logger.e('Error logging withdrawal: $e');
    }
  }

  /// Log shop hours update
  Future<void> logShopHoursUpdated() async {
    try {
      await _analytics.logEvent(name: 'shop_hours_updated');
      _logger.d('Shop hours update logged');
    } catch (e) {
      _logger.e('Error logging shop hours update: $e');
    }
  }

  /// Log profile update
  Future<void> logProfileUpdated() async {
    try {
      await _analytics.logEvent(name: 'profile_updated');
      _logger.d('Profile update logged');
    } catch (e) {
      _logger.e('Error logging profile update: $e');
    }
  }

  /// Log provider sign up
  Future<void> logSignUp({
    required String method,
  }) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      _logger.d('Sign up logged: $method');
    } catch (e) {
      _logger.e('Error logging sign up: $e');
    }
  }

  /// Log provider login
  Future<void> logLogin({
    required String method,
  }) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      _logger.d('Login logged: $method');
    } catch (e) {
      _logger.e('Error logging login: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.e('Error setting user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _logger.d('User property set: $name = $value');
    } catch (e) {
      _logger.e('Error setting user property: $e');
    }
  }

  /// Log app open
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      _logger.d('App open logged');
    } catch (e) {
      _logger.e('Error logging app open: $e');
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
      _logger.d('Error logged: $error');
    } catch (e) {
      _logger.e('Error logging error: $e');
    }
  }
}
