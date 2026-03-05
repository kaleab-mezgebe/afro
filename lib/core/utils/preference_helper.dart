import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class PreferenceHelper {
  static Future<void> navigateAfterAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final preferenceSelected = prefs.getBool('preference_selected') ?? false;

    if (preferenceSelected) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.preferenceSelection);
    }
  }

  static Future<String> getUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_preference') ?? 'all';
  }

  static Future<void> setUserPreference(String preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preference', preference);
    await prefs.setBool('preference_selected', true);
  }

  static Future<void> clearPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_preference');
    await prefs.setBool('preference_selected', false);
  }
}
