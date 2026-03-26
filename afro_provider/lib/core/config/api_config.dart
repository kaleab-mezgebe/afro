class ApiConfig {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:3001/api/v1';

  // For Android emulator use: http://10.0.2.2:3001/api/v1
  // For iOS simulator use: http://localhost:3001/api/v1
  // For physical device use: http://YOUR_IP:3001/api/v1

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
