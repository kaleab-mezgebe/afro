import 'package:get/get.dart';
import '../../../core/services/firebase_messaging_service.dart';

class NotificationController extends GetxController {
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  final RxString fcmToken = ''.obs;
  final RxBool isNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFCMToken();
  }

  void _loadFCMToken() {
    fcmToken.value = _messagingService.fcmToken ?? '';
  }

  /// Subscribe to booking updates
  Future<void> subscribeToBookingUpdates(String userId) async {
    await _messagingService.subscribeToTopic('user_$userId');
    await _messagingService.subscribeToTopic('all_users');
  }

  /// Unsubscribe from booking updates
  Future<void> unsubscribeFromBookingUpdates(String userId) async {
    await _messagingService.unsubscribeFromTopic('user_$userId');
  }

  /// Get FCM token for sending to backend
  String? getFCMToken() {
    return _messagingService.fcmToken;
  }
}
