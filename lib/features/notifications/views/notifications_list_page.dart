import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_list_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/push_notification.dart' as pn;

class NotificationsListPage extends GetView<NotificationsListController> {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(
            () => controller.notifications.isNotEmpty
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppTheme.primaryYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    // Convert notification type
    pn.NotificationType type;
    switch (notification.type) {
      case NotificationType.booking:
        type = pn.NotificationType.booking;
        break;
      case NotificationType.promotion:
        type = pn.NotificationType.promotion;
        break;
      case NotificationType.reminder:
        type = pn.NotificationType.reminder;
        break;
      case NotificationType.update:
        type = pn.NotificationType.info;
        break;
    }

    return pn.ModernPushNotification(
      title: notification.title,
      body: notification.message,
      type: type,
      timestamp: DateTime.now().subtract(
        const Duration(minutes: 5),
      ), // Parse from notification.timeAgo
      onTap: () => controller.onNotificationTap(notification),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: AppTheme.grey300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something arrives',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
