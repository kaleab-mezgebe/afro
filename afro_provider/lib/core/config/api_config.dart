class ApiConfig {
  // ─── CHANGE THIS when your Wi-Fi IP changes ───────────────────────────────
  // For Android emulator use: http://10.0.2.2:3001/api/v1
  // For iOS simulator use: http://localhost:3001/api/v1
  // For physical device use: http://YOUR_IP:3001/api/v1
  static const String _devHost = 'localhost';
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
