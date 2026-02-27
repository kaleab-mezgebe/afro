import 'package:get/get.dart';

import '../controllers/user_registration_controller.dart';

class UserRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRegistrationController>(
      () => UserRegistrationController(),
    );
  }
}
