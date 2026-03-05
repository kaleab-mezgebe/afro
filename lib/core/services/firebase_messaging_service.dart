import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../features/notifications/controllers/notifications_list_controller.dart';
import '../../routes/app_routes.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i('Background message: ${message.messageId}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Get FCM token with retry logic
  Future<void> _getFCMTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        _logger.i(
          'Attempting to get FCM token (attempt ${i + 1}/$maxRetries)...',
        );
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          _logger.i('✅ FCM Token obtained successfully!');
          _logger.i('FCM Token: $_fcmToken');
          _logger.i(
            'Copy this token to test notifications in Firebase Console',
          );
          return;
        } else {
          _logger.w('Token is null, retrying...');
        }
      } catch (e) {
        _logger.e('❌ Attempt ${i + 1}/$maxRetries failed');
        _logger.e('Error details: $e');
        if (e.toString().contains('FIS_AUTH_ERROR')) {
          _logger.e('');
          _logger.e('🔧 FIS_AUTH_ERROR detected. Possible solutions:');
          _logger.e(
            '1. Enable Firebase Installations API in Google Cloud Console',
          );
          _logger.e('2. Check API key restrictions');
          _logger.e('3. Verify internet connection');
          _logger.e('4. Wait a few minutes and try again');
          _logger.e('');
        }
        if (i < maxRetries - 1) {
          int waitSeconds = 2 * (i + 1);
          _logger.i('Waiting $waitSeconds seconds before retry...');
          await Future.delayed(Duration(seconds: waitSeconds));
        }
      }
    }
    _logger.e('❌ Failed to get FCM token after $maxRetries attempts');
    _logger.w(
      'App will continue without FCM token. Topic notifications may still work.',
    );
  }

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');
      } else {
        _logger.w('User declined notification permission');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token with retry
      await _getFCMTokenWithRetry();

      // Subscribe to a default topic (works even if token fails)
      try {
        await _messaging.subscribeToTopic('all_users');
        _logger.i('Subscribed to all_users topic');
      } catch (e) {
        _logger.w('Failed to subscribe to topic: $e');
      }

      // Listen to token refresh
      _messaging.onTokenRefresh
          .listen((newToken) {
            _fcmToken = newToken;
            _logger.i('FCM Token refreshed: $newToken');
            // TODO: Send token to your backend
          })
          .onError((error) {
            _logger.w('Token refresh error: $error');
          });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _logger.i('Firebase Messaging initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase Messaging: $e');
    }
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _logger.i('Notification tapped: ${details.payload}');
        // Handle notification tap
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('Foreground message received: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Add to notifications list
    _addToNotificationsList(message);

    if (notification != null && android != null) {
      _showLocalNotification(notification, message.data);
    }
  }

  /// Add notification to the in-app notifications list
  void _addToNotificationsList(RemoteMessage message) {
    try {
      if (Get.isRegistered<NotificationsListController>()) {
        final controller = Get.find<NotificationsListController>();

        final title = message.notification?.title ?? 'New Notification';
        final body = message.notification?.body ?? '';

        // Determine notification type from data
        NotificationType type = NotificationType.update;
        if (message.data.containsKey('type')) {
          switch (message.data['type']) {
            case 'booking':
              type = NotificationType.booking;
              break;
            case 'promotion':
              type = NotificationType.promotion;
              break;
            case 'reminder':
              type = NotificationType.reminder;
              break;
            default:
              type = NotificationType.update;
          }
        }

        controller.addNotification(
          title: title,
          message: body,
          type: type,
          data: message.data,
        );

        _logger.i('Notification added to list');
      }
    } catch (e) {
      _logger.w('Could not add notification to list: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(
    RemoteNotification notification,
    Map<String, dynamic> data,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    _logger.i('Notification tapped: ${message.messageId}');

    // Add to notifications list first (in case it wasn't added yet)
    _addToNotificationsList(message);

    // Navigate to notifications list page
    try {
      Get.offAllNamed('/');
      // Small delay to ensure home is loaded, then navigate to notifications
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.toNamed(AppRoutes.notifications);
      });
      _logger.i('Navigated to notifications list');
    } catch (e) {
      _logger.e('Error navigating to notifications: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic: $e');
    }
  }
}
