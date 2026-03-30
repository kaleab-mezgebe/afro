import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class NotificationService {
  static BuildContext? _context;
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static void showNotification({
    required String message,
    required NotificationType type,
    String? title,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (_context == null) return;

    if (_isShowing) {
      _hideNotification();
    }

    final scaffoldMessenger = ScaffoldMessenger.of(_context!);

    // Clear any existing snack bars
    scaffoldMessenger.hideCurrentSnackBar();

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue.shade600;
        textColor = Colors.white;
        icon = Icons.info;
        break;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  static void _hideNotification() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static void showSuccess(String message, {String? title}) {
    showNotification(
      message: message,
      type: NotificationType.success,
      title: title ?? 'Success',
    );
  }

  static void showError(String message, {String? title}) {
    showNotification(
      message: message,
      type: NotificationType.error,
      title: title ?? 'Error',
      duration: const Duration(seconds: 6),
    );
  }

  static void showWarning(String message, {String? title}) {
    showNotification(
      message: message,
      type: NotificationType.warning,
      title: title ?? 'Warning',
    );
  }

  static void showInfo(String message, {String? title}) {
    showNotification(
      message: message,
      type: NotificationType.info,
      title: title ?? 'Info',
    );
  }
}

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
