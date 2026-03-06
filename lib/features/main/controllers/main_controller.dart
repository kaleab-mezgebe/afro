import 'package:get/get.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  var bookingTabIndex = 0.obs;

  void changePage(int index) {
    if (index >= 0 && index < 5) {
      currentIndex.value = index;
    }
  }

  void changeBookingTab(int index) {
    bookingTabIndex.value = index;
  }
}
