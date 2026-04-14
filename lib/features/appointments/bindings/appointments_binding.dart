import 'package:get/get.dart';

import '../../../data/datasources/local/local_storage.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/usecases/booking/create_booking.dart';
import '../../../domain/usecases/booking/get_availability.dart';
import '../../../domain/usecases/booking/get_booking_history.dart';
import '../../../domain/usecases/booking/get_providers.dart';
import '../../../domain/usecases/booking/get_services.dart';
import '../../../core/config/api_config.dart';
import '../controllers/appointments_controller.dart';

class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    // Core dependencies (if not already registered)
    if (!Get.isRegistered<LocalStorage>()) {
      Get.lazyPut<LocalStorage>(() => LocalStorageImpl());
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClientImpl(baseUrl: ApiConfig.baseUrl));
    }

    // Repository (if not already registered)
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(
        () => BookingRepositoryImpl(
          apiClient: Get.find<ApiClient>(),
          localStorage: Get.find<LocalStorage>(),
        ),
      );
    }

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

    // Controller
    Get.lazyPut<AppointmentsController>(
      () => AppointmentsController(
        getProviders: Get.find<GetProviders>(),
        getServices: Get.find<GetServices>(),
        getAvailability: Get.find<GetAvailability>(),
        createBooking: Get.find<CreateBooking>(),
        getBookingHistory: Get.find<GetBookingHistory>(),
      ),
    );
  }
}
