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

/// Enhanced initial binding that registers all API services
/// All services use lazy loading to avoid blocking app startup
class InitialBindingEnhanced extends Bindings {
  @override
  void dependencies() {
    // Enhanced API Client - lazy but persistent
    Get.lazyPut<EnhancedApiClient>(
      () => EnhancedApiClient(FirebaseAuth.instance),
      fenix: true,
    );

    // API Services - Lazy loading for better performance
    Get.lazyPut<BarberApiService>(
      () => BarberApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<AppointmentApiService>(
      () => AppointmentApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<CustomerApiService>(
      () => CustomerApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<FavoriteApiService>(
      () => FavoriteApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<PaymentApiService>(
      () => PaymentApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<ReviewApiService>(
      () => ReviewApiService(Get.find<EnhancedApiClient>()),
    );

    Get.lazyPut<ServiceApiService>(
      () => ServiceApiService(Get.find<EnhancedApiClient>()),
    );
  }
}
