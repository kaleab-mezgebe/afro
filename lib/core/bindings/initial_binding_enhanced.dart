import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/enhanced_api_client.dart';
import '../services/barber_api_service.dart';
import '../services/appointment_api_service.dart';
import '../services/customer_api_service.dart';
import '../services/favorite_api_service.dart';
import '../services/payment_api_service.dart';
import '../services/review_api_service.dart';
import '../services/service_api_service.dart';
import '../services/auth_api_service.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/booking/create_booking.dart';
import '../../domain/usecases/booking/get_availability.dart';
import '../../domain/usecases/booking/get_booking_history.dart';
import '../../domain/usecases/booking/get_providers.dart';
import '../../domain/usecases/booking/get_services.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../../domain/usecases/search/search_providers.dart';
import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';

/// Enhanced initial binding that registers all API services
/// All services use lazy loading to avoid blocking app startup
class InitialBindingEnhanced extends Bindings {
  @override
  void dependencies() {
    // Core Controllers - Initialize immediately
    Get.put<AuthController>(AuthController(), permanent: true);

    // Core Components
    Get.put<LocalStorage>(LocalStorageImpl(), permanent: true);
    
    // Legacy API Client for backwards compatibility
    Get.lazyPut<ApiClient>(
      () => ApiClientImpl(baseUrl: AppConstants.apiBaseUrl),
      fenix: true,
    );

    // Enhanced API Client - lazy but persistent
    Get.lazyPut<EnhancedApiClient>(
      () => EnhancedApiClient(FirebaseAuth.instance),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        localStorage: Get.find<LocalStorage>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(localStorage: Get.find<LocalStorage>()),
      fenix: true,
    );
    Get.lazyPut<SearchRepository>(
      () => SearchRepositoryImpl(localStorage: Get.find<LocalStorage>()),
      fenix: true,
    );

    // Use cases
    Get.lazyPut<GetProviders>(
      () => GetProviders(Get.find<BookingRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetServices>(
      () => GetServices(Get.find<BookingRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetAvailability>(
      () => GetAvailability(Get.find<BookingRepository>()),
      fenix: true,
    );
    Get.lazyPut<CreateBooking>(
      () => CreateBooking(Get.find<BookingRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetBookingHistory>(
      () => GetBookingHistory(Get.find<BookingRepository>()),
      fenix: true,
    );
    Get.lazyPut<SearchProviders>(
      () => SearchProviders(Get.find<SearchRepository>()),
      fenix: true,
    );
    Get.lazyPut<Login>(
      () => Login(Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<Register>(
      () => Register(Get.find<AuthRepository>()),
      fenix: true,
    );

    // API Services - Lazy loading for better performance
    Get.lazyPut<AuthApiService>(
      () => AuthApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<BarberApiService>(
      () => BarberApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<AppointmentApiService>(
      () => AppointmentApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<CustomerApiService>(
      () => CustomerApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<FavoriteApiService>(
      () => FavoriteApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<PaymentApiService>(
      () => PaymentApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ReviewApiService>(
      () => ReviewApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ServiceApiService>(
      () => ServiceApiService(Get.find<EnhancedApiClient>()),
      fenix: true,
    );
  }
}
