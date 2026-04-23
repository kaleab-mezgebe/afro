class ApiConfig {
  // ─── CHANGE THIS when your Wi-Fi IP changes ───────────────────────────────
  // Run in terminal:  ipconfig | findstr "IPv4"   (Windows)
  //                   ifconfig | grep "inet "      (Mac/Linux)
  //
  // Physical Android device → your PC's Wi-Fi IP (e.g. 192.168.1.9)
  // Android emulator        → 10.0.2.2  (special alias for host loopback)
  // iOS simulator           → 127.0.0.1
  //
  // If you're using an EMULATOR, change _devHost to '10.0.2.2'
  static const String _devHost = '192.168.1.6';
  static const int _devPort = 3001;
  // ─────────────────────────────────────────────────────────────────────────

  static const String baseUrl = 'http://$_devHost:$_devPort/api/v1';

  // API Endpoints
  static const String auth = '/auth';
  static const String barbers = '/barbers';
  static const String appointments = '/appointments';
  static const String services = '/services';
  static const String reviews = '/reviews';
  static const String favorites = '/favorites';
  static const String customers = '/customers';

  // Timeouts — 10s connect is enough; if the server is reachable it responds fast
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
