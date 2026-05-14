import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern push notification widget with improved design
class ModernPushNotification extends StatelessWidget {
  final String title;
  final String body;
  final String? imageUrl;
  final IconData? icon;
  final NotificationType type;
  final DateTime timestamp;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const ModernPushNotification({
    super.key,
    required this.title,
    required this.body,
    this.imageUrl,
    this.icon,
    this.type = NotificationType.info,
    required this.timestamp,
    this.onTap,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppTheme.primaryYellow.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: _getTypeColor().withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            icon ?? _getDefaultIcon(),
                            color: _getTypeColor(),
                            size: 28,
                          ),
                        ),
                      )
                    : Icon(
                        icon ?? _getDefaultIcon(),
                        color: _getTypeColor(),
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onDismiss != null)
                          GestureDetector(
                            onTap: onDismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppTheme.grey400,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.grey600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey500,
                          ),
                        ),
                        const Spacer(),
                        if (onAction != null)
                          GestureDetector(
                            onTap: onAction,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case NotificationType.booking:
        return AppTheme.primaryYellow;
      case NotificationType.promotion:
        return const Color(0xFF9C27B0);
      case NotificationType.reminder:
        return const Color(0xFF2196F3);
      case NotificationType.rating:
        return const Color(0xFFFFA000);
      case NotificationType.success:
        return AppTheme.success;
      case NotificationType.warning:
        return AppTheme.warning;
      case NotificationType.error:
        return AppTheme.error;
      default:
        return AppTheme.primaryYellow;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case NotificationType.booking:
        return Icons.calendar_today_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.rating:
        return Icons.star_rounded;
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.error:
        return Icons.error_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Notification type enum
enum NotificationType {
  booking,
  promotion,
  reminder,
  rating,
  success,
  warning,
  error,
  info,
}

/// Notification list widget
class NotificationList extends StatelessWidget {
  final List<ModernPushNotification> notifications;
  final VoidCallback? onClearAll;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: AppTheme.grey300,
              ),
              SizedBox(height: 16),
              Text(
                'No notifications',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'re all caught up!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
              if (onClearAll != null)
                GestureDetector(
                  onTap: onClearAll,
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Notification list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) => notifications[index],
        ),
      ],
    );
  }
}

/// Notification settings widget
class NotificationSettings extends StatelessWidget {
  final bool bookingReminders;
  final bool promotions;
  final bool newServices;
  final bool ratingRequests;
  final ValueChanged<bool> onBookingRemindersChanged;
  final ValueChanged<bool> onPromotionsChanged;
  final ValueChanged<bool> onNewServicesChanged;
  final ValueChanged<bool> onRatingRequestsChanged;

  const NotificationSettings({
    super.key,
    required this.bookingReminders,
    required this.promotions,
    required this.newServices,
    required this.ratingRequests,
    required this.onBookingRemindersChanged,
    required this.onPromotionsChanged,
    required this.onNewServicesChanged,
    required this.onRatingRequestsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 20),
          _NotificationToggle(
            icon: Icons.calendar_today_rounded,
            title: 'Booking Reminders',
            description: 'Get notified before your appointments',
            value: bookingReminders,
            onChanged: onBookingRemindersChanged,
          ),
          const SizedBox(height: 16),
          _NotificationToggle(
            icon: Icons.local_offer_rounded,
            title: 'Promotions',
            description: 'Receive special offers and discounts',
            value: promotions,
            onChanged: onPromotionsChanged,
          ),
          const SizedBox(height: 16),
          _NotificationToggle(
            icon: Icons.spa_rounded,
            title: 'New Services',
            description: 'Be the first to know about new services',
            value: newServices,
            onChanged: onNewServicesChanged,
          ),
          const SizedBox(height: 16),
          _NotificationToggle(
            icon: Icons.star_rounded,
            title: 'Rating Requests',
            description: 'Rate your experience after appointments',
            value: ratingRequests,
            onChanged: onRatingRequestsChanged,
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryYellow, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryYellow,
          activeTrackColor: AppTheme.primaryYellow.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
