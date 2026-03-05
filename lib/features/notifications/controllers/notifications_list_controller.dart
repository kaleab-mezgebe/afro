import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum NotificationType { booking, promotion, reminder, update }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.update,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }
}

class NotificationsListController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  static const String _storageKey = 'notifications_list';

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        notifications.value = decoded
            .map((item) => NotificationItem.fromJson(item))
            .toList();
      } else {
        _loadSampleNotifications();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _loadSampleNotifications();
    }
  }

  void _loadSampleNotifications() {
    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'Welcome!',
        message:
            'Thank you for using our app. Tap the notification bell to see updates!',
        type: NotificationType.update,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> notificationsJson = notifications
          .map((n) => n.toJson())
          .toList();
      await prefs.setString(_storageKey, json.encode(notificationsJson));
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.update,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );

    notifications.insert(0, notification);
    await _saveNotifications();
  }

  void onNotificationTap(NotificationItem notification) {
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1 && !notification.isRead) {
      notifications[index] = notification.copyWith(isRead: true);
      _saveNotifications();
    }

    if (notification.data != null) {
      final type = notification.data!['type'];
      switch (type) {
        case 'booking':
          break;
        case 'promotion':
          Get.back();
          break;
        default:
          break;
      }
    }
  }

  Future<void> markAllAsRead() async {
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> clearAll() async {
    notifications.clear();
    await _saveNotifications();
  }
}
