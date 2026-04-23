import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../notifications/controllers/notifications_list_controller.dart';
import '../../appointments/controllers/appointments_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';

import '../../../core/services/customer_api_service.dart';
import '../../../core/services/favorite_api_service.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../data/repositories/search_repository_impl.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/search_repository.dart';

import '../../../domain/usecases/booking/create_booking.dart';
import '../../../domain/usecases/booking/get_availability.dart';
import '../../../domain/usecases/booking/get_booking_history.dart';
import '../../../domain/usecases/booking/get_providers.dart';
import '../../../domain/usecases/booking/get_services.dart';

import '../../../domain/usecases/profile/change_password.dart';
import '../../../domain/usecases/profile/get_profile.dart';
import '../../../domain/usecases/profile/update_preferences.dart';
import '../../../domain/usecases/profile/update_profile.dart';

import '../../../domain/usecases/search/search_providers.dart';

import '../../../data/datasources/local/local_storage.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<NotificationsListController>(
      () => NotificationsListController(),
    );

    // Repositories
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(
          customerApiService: Get.find<CustomerApiService>(),
        ),
      );
    }
    if (!Get.isRegistered<SearchRepository>()) {
      Get.lazyPut<SearchRepository>(
        () => SearchRepositoryImpl(localStorage: Get.find<LocalStorage>()),
      );
    }

    // Profile Use Cases
    Get.lazyPut<GetProfile>(() => GetProfile(Get.find<ProfileRepository>()));
    Get.lazyPut<UpdateProfile>(
      () => UpdateProfile(Get.find<ProfileRepository>()),
    );
    Get.lazyPut<ChangePassword>(
      () => ChangePassword(Get.find<ProfileRepository>()),
    );
    Get.lazyPut<UpdatePreferences>(
      () => UpdatePreferences(Get.find<ProfileRepository>()),
    );

    // Search Use Cases
    Get.lazyPut<SearchProviders>(
      () => SearchProviders(Get.find<SearchRepository>()),
    );

    // Controllers with dependencies
    Get.lazyPut<AppointmentsController>(
      () => AppointmentsController(
        getProviders: Get.find<GetProviders>(),
        getServices: Get.find<GetServices>(),
        getAvailability: Get.find<GetAvailability>(),
        createBooking: Get.find<CreateBooking>(),
        getBookingHistory: Get.find<GetBookingHistory>(),
      ),
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        getProfile: Get.find<GetProfile>(),
        updateProfile: Get.find<UpdateProfile>(),
        changePassword: Get.find<ChangePassword>(),
        updatePreferences: Get.find<UpdatePreferences>(),
        customerApiService: Get.find<CustomerApiService>(),
      ),
    );

    Get.lazyPut<SearchController>(
      () => SearchController(
        searchProviders: Get.find<SearchProviders>(),
        searchRepository: Get.find<SearchRepository>(),
      ),
    );

    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        favoriteApiService: Get.find<FavoriteApiService>(),
      ),
    );
  }
}
