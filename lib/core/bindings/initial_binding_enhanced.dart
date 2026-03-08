import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/firebase_user_service.dart';
import '../services/enhanced_api_client.dart';
import '../services/appointment_api_service.dart';
import '../services/barber_api_service.dart';
import '../services/customer_api_service.dart';
import '../services/favorite_api_service.dart';
import '../services/review_api_service.dart';
import '../services/service_api_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/local/local_storage_impl.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../constants/app_constants.dart';

/// Enhanced Initial Binding with full backend integration
///
/// This binding includes:
/// - Firebase Auth integration
/// - Enhanced API Client with automatic token injection
/// - 7 dedicated API services
/// - Backward compatibility with existing code
class InitialBindingEnhanced extends Bindings {
  @override
  void dependencies() {
    // Firebase
    Get.put<FirebaseAuth>(FirebaseAuth.instance, permanent: true);
    Get.put<FirebaseUserService>(FirebaseUserService(), permanent: true);

    // Enhanced API Client with Firebase Auth
    Get.put<EnhancedApiClient>(
      EnhancedApiClient(Get.find<FirebaseAuth>()),
      permanent: true,
    );

    // API Services - New backend-integrated services
    Get.lazyPut<AppointmentApiService>(
      () => AppointmentApiService(Get.find<EnhancedApiClient>()),
    );
    Get.lazyPut<BarberApiService>(
      () => BarberApiService(Get.find<EnhancedApiClient>()),
    );
    Get.lazyPut<CustomerApiService>(
      () => CustomerApiService(Get.find<EnhancedApiClient>()),
    );
    Get.lazyPut<FavoriteApiService>(
      () => FavoriteApiService(Get.find<EnhancedApiClient>()),
    );
    Get.lazyPut<ReviewApiService>(
      () => ReviewApiService(Get.find<EnhancedApiClient>()),
    );
    Get.lazyPut<ServiceApiService>(
      () => ServiceApiService(Get.find<EnhancedApiClient>()),
    );

    // Local Storage
    Get.put<LocalStorage>(LocalStorageImpl());

    // Legacy API Client (for backward compatibility)
    Get.lazyPut<ApiClient>(
      () => ApiClientImpl(baseUrl: AppConstants.apiBaseUrl),
    );

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => FirebaseAuthRepositoryImpl(
        localStorage: Get.find<LocalStorage>(),
        firebaseUserService: Get.find<FirebaseUserService>(),
      ),
    );

    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        localStorage: Get.find<LocalStorage>(),
      ),
    );
  }
}
