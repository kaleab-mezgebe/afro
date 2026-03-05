import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationSettingsPage extends GetView<NotificationController> {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Push Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive booking updates and offers'),
                value: controller.isNotificationEnabled.value,
                onChanged: (value) {
                  controller.isNotificationEnabled.value = value;
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'FCM Token',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.fcmToken.value.isEmpty
                            ? 'Loading token...'
                            : controller.fcmToken.value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (controller.fcmToken.value.isNotEmpty) {
                          Clipboard.setData(
                            ClipboardData(text: controller.fcmToken.value),
                          );
                          Get.snackbar(
                            'Copied',
                            'FCM token copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use this token to send test notifications from Firebase Console',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
