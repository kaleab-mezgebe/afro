import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void i(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void e(String message) {
    debugPrint('[ERROR] $message');
  }

  static void w(String message) {
    if (kDebugMode) debugPrint('[WARN] $message');
  }

  static void v(String message) {
    if (kDebugMode) debugPrint('[VERBOSE] $message');
  }
}

// Type alias for easier usage
typedef Logger = AppLogger;
