class ApiConfig {
  // Base URL - Change this to your backend URL
  // Your machine's Wi-Fi IP: 192.168.1.8, backend port: 3001
  static const String baseUrl = 'http://192.168.1.8:3001/api/v1';

  // For Android emulator use: http://10.0.2.2:3001/api/v1
  // For iOS simulator use: http://localhost:3001/api/v1
  // For physical device use: http://YOUR_WIFI_IP:3001/api/v1
  // Run: ipconfig | findstr "IPv4" to get your current IP

  // API Endpoints
  static const String auth = '/auth';
  static const String barbers = '/barbers';
  static const String appointments = '/appointments';
  static const String services = '/services';
  static const String reviews = '/reviews';
  static const String favorites = '/favorites';
  static const String customers = '/customers';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
