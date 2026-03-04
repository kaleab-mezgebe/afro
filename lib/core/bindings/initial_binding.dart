import 'package:get/get.dart';

import '../../core/controllers/auth_controller.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/booking/create_booking.dart';
import '../../domain/usecases/booking/get_availability.dart';
import '../../domain/usecases/booking/get_booking_history.dart';
import '../../domain/usecases/booking/get_providers.dart';
import '../../domain/usecases/booking/get_services.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../constants/app_constants.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Controllers - Initialize immediately
    Get.put<AuthController>(AuthController());

    // Core
    Get.lazyPut<LocalStorage>(() => LocalStorageImpl());
    Get.lazyPut<ApiClient>(
      () => ApiClientImpl(baseUrl: AppConstants.apiBaseUrl),
    );

    // Repositories
    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        localStorage: Get.find<LocalStorage>(),
      ),
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(localStorage: Get.find<LocalStorage>()),
    );

    // Use cases
    Get.lazyPut<GetProviders>(
      () => GetProviders(Get.find<BookingRepository>()),
    );
    Get.lazyPut<GetServices>(() => GetServices(Get.find<BookingRepository>()));
    Get.lazyPut<GetAvailability>(
      () => GetAvailability(Get.find<BookingRepository>()),
    );
    Get.lazyPut<CreateBooking>(
      () => CreateBooking(Get.find<BookingRepository>()),
    );
    Get.lazyPut<GetBookingHistory>(
      () => GetBookingHistory(Get.find<BookingRepository>()),
    );
    Get.lazyPut<Login>(() => Login(Get.find<AuthRepository>()));
    Get.lazyPut<Register>(() => Register(Get.find<AuthRepository>()));
  }
}
