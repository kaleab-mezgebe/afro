import 'package:get/get.dart';

import '../../../core/services/customer_api_service.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/usecases/profile/change_password.dart';
import '../../../domain/usecases/profile/get_profile.dart';
import '../../../domain/usecases/profile/update_preferences.dart';
import '../../../domain/usecases/profile/update_profile.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(
        customerApiService: Get.find<CustomerApiService>(),
      ),
    );

    Get.lazyPut<GetProfile>(() => GetProfile(Get.find()));
    Get.lazyPut<UpdateProfile>(() => UpdateProfile(Get.find()));
    Get.lazyPut<ChangePassword>(() => ChangePassword(Get.find()));
    Get.lazyPut<UpdatePreferences>(() => UpdatePreferences(Get.find()));

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        getProfile: Get.find(),
        updateProfile: Get.find(),
        changePassword: Get.find(),
        updatePreferences: Get.find(),
      ),
    );
  }
}
