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
    if (!Get.isRegistered<GetProviders>()) {
      Get.put<GetProviders>(GetProviders(Get.find<BookingRepository>()));
    }
    if (!Get.isRegistered<GetServices>()) {
      Get.put<GetServices>(GetServices(Get.find<BookingRepository>()));
    }
    if (!Get.isRegistered<GetAvailability>()) {
      Get.put<GetAvailability>(GetAvailability(Get.find<BookingRepository>()));
    }
    if (!Get.isRegistered<CreateBooking>()) {
      Get.put<CreateBooking>(CreateBooking(Get.find<BookingRepository>()));
    }
    if (!Get.isRegistered<GetBookingHistory>()) {
      Get.put<GetBookingHistory>(
        GetBookingHistory(Get.find<BookingRepository>()),
      );
    }

    // Controller — fenix:true keeps it alive across page pushes so
    // selectedProvider/selectedService/selectedTimeSlot survive navigation
    if (!Get.isRegistered<AppointmentsController>()) {
      Get.put<AppointmentsController>(
        AppointmentsController(
          getProviders: Get.find<GetProviders>(),
          getServices: Get.find<GetServices>(),
          getAvailability: Get.find<GetAvailability>(),
          createBooking: Get.find<CreateBooking>(),
          getBookingHistory: Get.find<GetBookingHistory>(),
        ),
        permanent: false,
      );
    }
  }
}
