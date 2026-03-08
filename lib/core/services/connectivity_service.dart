import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Service for monitoring network connectivity status
/// Provides real-time updates and offline detection
class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.wifi.obs;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startMonitoring();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.e('Error checking connectivity: $e');
      isOnline.value = true; // Assume online on error
    }
  }

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        AppLogger.e('Connectivity monitoring error: $error');
      },
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = isOnline.value;
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    connectionType.value = result;
    isOnline.value = result != ConnectivityResult.none;

    AppLogger.d(
      'Connection status: ${isOnline.value ? "Online" : "Offline"} ($result)',
    );

    // Show user-friendly notifications
    if (!isOnline.value && wasOnline) {
      _showOfflineNotification();
    } else if (isOnline.value && !wasOnline) {
      _showOnlineNotification();
    }
  }

  void _showOfflineNotification() {
    Get.snackbar(
      'Offline',
      'You are currently offline. Some features may be limited.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void _showOnlineNotification() {
    Get.snackbar(
      'Online',
      'Connection restored',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  /// Check if device is connected to WiFi
  bool get isWifi => connectionType.value == ConnectivityResult.wifi;

  /// Check if device is connected to mobile data
  bool get isMobile => connectionType.value == ConnectivityResult.mobile;

  /// Check if device has any connection
  bool get hasConnection => isOnline.value;

  /// Manually check connectivity (useful for retry logic)
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return isOnline.value;
    } catch (e) {
      AppLogger.e('Error checking connection: $e');
      return false;
    }
  }
}
