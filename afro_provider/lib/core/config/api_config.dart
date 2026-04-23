class ApiConfig {
  // ─── CHANGE THIS when your Wi-Fi IP changes ───────────────────────────────
  // Run in terminal:  ipconfig | findstr "IPv4"   (Windows)
  //                   ifconfig | grep "inet "      (Mac/Linux)
  static const String _devHost = '192.168.1.6';
  static const int _devPort = 3001;
  // ─────────────────────────────────────────────────────────────────────────

  static const String baseUrl = 'http://$_devHost:$_devPort/api/v1';

  // API Endpoints
  static const String auth = '/auth';
  static const String providers = '/providers';
  static const String shops = '/providers/shops';
  static const String staff = '/providers/staff';
  static const String services = '/providers/services';
  static const String appointments = '/providers/appointments';
  static const String analytics = '/providers/analytics';
  static const String portfolio = '/providers/portfolio';
  static const String customers = '/providers/customers';
  static const String earnings = '/providers/earnings';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
