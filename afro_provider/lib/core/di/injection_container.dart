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
import '../services/analytics_api_service.dart';
import '../services/customer_service.dart';
import '../services/portfolio_service.dart';

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
AnalyticsService? analyticsService;
late AnalyticsApiService analyticsApiService;
late CustomerService customerService;
late PortfolioService portfolioService;

Future<void> initializeDependencies() async {
  try {
    print('Initializing dependencies...');

    // Shared Preferences
    sharedPreferences = await SharedPreferences.getInstance();
    print('SharedPreferences initialized');

    // API Client
    apiClient = ApiClient();
    print('ApiClient initialized');

    // Firebase Auth - Only initialize if Firebase was successfully initialized
    FirebaseAuth? firebaseAuth;
    try {
      firebaseAuth = FirebaseAuth.instance;
      print('FirebaseAuth initialized');
    } catch (e) {
      print('FirebaseAuth initialization failed: $e');
      firebaseAuth = null;
    }

    // Services
    authService = AuthService(apiClient, firebaseAuth);
    providerService = ProviderService(apiClient);
    shopService = ShopService(apiClient);
    staffService = StaffService(apiClient);
    serviceService = ServiceService(apiClient);
    appointmentService = AppointmentService(apiClient);

    // Analytics Service - Only initialize if Firebase is available
    try {
      analyticsService =
          AnalyticsService(); // Firebase Analytics (no parameters)
      print('AnalyticsService initialized');
    } catch (e) {
      print('AnalyticsService initialization failed: $e');
      analyticsService = null;
    }

    analyticsApiService =
        AnalyticsApiService(apiClient); // Backend API analytics
    customerService = CustomerService(apiClient);
    portfolioService = PortfolioService(apiClient);

    print('All services initialized successfully');
    _logger.i('Dependencies initialized');
  } catch (e, stackTrace) {
    print('Error initializing dependencies: $e');
    print('Stack trace: $stackTrace');
    _logger.e('Failed to initialize dependencies',
        error: e, stackTrace: stackTrace);

    // Re-throw to let the app handle the error gracefully
    rethrow;
  }
}
