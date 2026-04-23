import 'dart:io';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart' as core_auth;
import '../../../core/services/customer_api_service.dart';

import '../../../domain/entities/profile.dart';
import '../../../domain/usecases/profile/get_profile.dart';
import '../../../domain/usecases/profile/update_profile.dart';
import '../../../domain/usecases/profile/change_password.dart';
import '../../../domain/usecases/profile/update_preferences.dart';

class ProfileController extends GetxController {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final ChangePassword _changePassword;
  final UpdatePreferences _updatePreferences;
  final CustomerApiService _customerApiService;

  ProfileController({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required ChangePassword changePassword,
    required UpdatePreferences updatePreferences,
    required CustomerApiService customerApiService,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       _changePassword = changePassword,
       _updatePreferences = updatePreferences,
       _customerApiService = customerApiService;

  final Rx<Profile?> _profile = Rx<Profile?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  Profile? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      _profile.value = await _getProfile();
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Upload profile picture and return the hosted URL
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final url = await _customerApiService.uploadProfilePicture(imageFile);
      return url;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to upload image: ${e.toString()}');
      return null;
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
    String? avatar,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final updatedProfile = await _updateProfile(
        name: name,
        phoneNumber: phoneNumber,
        avatar: avatar,
        bio: bio,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      _profile.value = updatedProfile;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      Get.snackbar('Success', 'Password changed successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to change password: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePreferences(List<String> preferences) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _updatePreferences(preferences);

      await loadProfile(); // Reload to get updated profile
      Get.snackbar('Success', 'Preferences updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update preferences: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }

  Future<void> logout() async {
    final authController = Get.find<core_auth.AuthController>();
    await authController.logout();
  }
}
