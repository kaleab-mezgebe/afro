import 'package:customer_app/domain/usecases/search/search_providers.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(
      () => SearchController(searchProviders: Get.find<SearchProviders>()),
    );
  }
}
