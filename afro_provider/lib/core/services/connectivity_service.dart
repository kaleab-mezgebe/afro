import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnlineStream;
});

/// Service for monitoring network connectivity status
/// Provides real-time updates and offline detection
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  final _isOnlineController = StreamController<bool>.broadcast();
  Stream<bool> get isOnlineStream => _isOnlineController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityResult _connectionType = ConnectivityResult.wifi;
  ConnectivityResult get connectionType => _connectionType;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _initConnectivity();
    _startMonitoring();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      _isOnline = true; // Assume online on error
    }
  }

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        _logger.e('Connectivity monitoring error: $error');
      },
    );
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    _connectionType = result;
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    _isOnlineController.add(_isOnline);

    _logger
        .d('Connection status: ${_isOnline ? "Online" : "Offline"} ($result)');

    // Log status changes
    if (!_isOnline && wasOnline) {
      _logger.w('Device went offline');
    } else if (_isOnline && !wasOnline) {
      _logger.i('Device back online');
    }
  }

  /// Check if device is connected to WiFi
  bool get isWifi => _connectionType == ConnectivityResult.wifi;

  /// Check if device is connected to mobile data
  bool get isMobile => _connectionType == ConnectivityResult.mobile;

  /// Manually check connectivity (useful for retry logic)
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isOnline;
    } catch (e) {
      _logger.e('Error checking connection: $e');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _isOnlineController.close();
  }
}
