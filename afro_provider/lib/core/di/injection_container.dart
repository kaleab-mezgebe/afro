import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';
import '../services/provider_service.dart';
import '../services/shop_service.dart';
import '../services/staff_service.dart';
import '../services/service_service.dart';
import '../services/appointment_service.dart';
import '../services/analytics_service.dart';

final _logger = Logger();

// Global instances
late SharedPreferences sharedPreferences;
late ApiClient apiClient;
late AuthService authService;
late ProviderService providerService;
late ShopService shopService;
late StaffService staffService;
late ServiceService serviceService;
late AppointmentService appointmentService;
late AnalyticsService analyticsService;

Future<void> initializeDependencies() async {
  // Shared Preferences
  sharedPreferences = await SharedPreferences.getInstance();

  // API Client
  apiClient = ApiClient();

  // Firebase Auth
  final firebaseAuth = FirebaseAuth.instance;

  // Services
  authService = AuthService(apiClient, firebaseAuth);
  providerService = ProviderService(apiClient);
  shopService = ShopService(apiClient);
  staffService = StaffService(apiClient);
  serviceService = ServiceService(apiClient);
  appointmentService = AppointmentService(apiClient);
  analyticsService = AnalyticsService(apiClient);

  _logger.i('Dependencies initialized');
}
