import 'package:get/get.dart';

import '../../../core/services/favorite_api_service.dart';
import '../controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        favoriteApiService: Get.find<FavoriteApiService>(),
      ),
    );
  }
}
