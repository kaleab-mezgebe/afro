
class AppLogger {
  static void d(String message) {
    AppLogger.d(message);
  }

  static void i(String message) {
    AppLogger.i(message);
  }

  static void e(String message) {
    AppLogger.e(message);
  }

  static void w(String message) {
    AppLogger.w(message);
  }

  static void v(String message) {
    AppLogger.v(message);
  }
}

// Type alias for easier usage
typedef Logger = AppLogger;
