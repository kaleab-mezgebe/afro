// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../../domain/entities/user.dart';
import '../../../core/theme/butter_theme.dart';
import '../../../core/utils/preference_helper.dart';
import '../../../core/services/firebase_user_service.dart';
import '../../../data/repositories/firebase_auth_repository_impl.dart';
import '../../../data/datasources/local/local_storage.dart';

class UserRegistrationController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseUserService _firebaseUserService = FirebaseUserService();

  // Form fields
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString location = ''.obs;
  final RxString gender = ''.obs;
  final RxString dateOfBirth = ''.obs;
  final RxString hairType = ''.obs;
  final RxString skinType = ''.obs;
  final RxList<String> preferredServices = <String>[].obs;
  final RxString selectedImagePath = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Validation
  bool get isFirstNameValid => firstName.value.length >= 2;
  bool get isLastNameValid => lastName.value.length >= 2;
  bool get isPhoneNumberValid => phoneNumber.value.length >= 10;
  bool get isLocationValid => location.value.length >= 2;
  bool get isGenderValid => gender.value.isNotEmpty;
  bool get isDateOfBirthValid => dateOfBirth.value.isNotEmpty;
  bool get isHairTypeValid => hairType.value.isNotEmpty;
  bool get isSkinTypeValid => skinType.value.isNotEmpty;
  bool get hasPreferredServices => preferredServices.isNotEmpty;

  bool get canSubmit =>
      isFirstNameValid &&
      isLastNameValid &&
      isPhoneNumberValid &&
      isLocationValid &&
      isGenderValid &&
      isDateOfBirthValid &&
      isHairTypeValid &&
      isSkinTypeValid &&
      hasPreferredServices &&
      !isLoading.value;

  void setFirstName(String value) => firstName.value = value;
  void setLastName(String value) => lastName.value = value;
  void setPhoneNumber(String value) => phoneNumber.value = value;
  void setLocation(String value) => location.value = value;
  void setGender(String value) => gender.value = value;
  void setHairType(String value) => hairType.value = value;
  void setSkinType(String value) => skinType.value = value;
  void setDateOfBirth(String value) => dateOfBirth.value = value;

  void togglePreferredService(String service) {
    if (preferredServices.contains(service)) {
      preferredServices.remove(service);
    } else {
      preferredServices.add(service);
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
    );

    if (picked != null) {
      dateOfBirth.value = picked.toIso8601String();
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  Future<void> submitRegistration() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get current authenticated user
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found. Please sign in first.');
      }

      // Save complete user registration to Firebase
      final userProfile = await _firebaseUserService.saveUserRegistration(
        uid: currentUser.uid,
        name: '${firstName.value.trim()} ${lastName.value.trim()}',
        email: currentUser.email ?? '',
        phoneNumber: phoneNumber.value.trim().isEmpty
            ? null
            : phoneNumber.value.trim(),
        avatar: selectedImagePath.value.isNotEmpty
            ? selectedImagePath.value
            : currentUser.photoURL,
        firstName: firstName.value.trim(),
        lastName: lastName.value.trim(),
        location: location.value.trim(),
        gender: gender.value,
        dateOfBirth: dateOfBirth.value,
        hairType: hairType.value,
        skinType: skinType.value,
        preferredServices: preferredServices.toList(),
      );

      // Handle successful registration
      Get.snackbar(
        'Profile Complete!',
        'Welcome to AFRO, ${userProfile.name}!',
        backgroundColor: ButterTheme.successMint,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to preference selection or home
      await PreferenceHelper.navigateAfterAuth();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        error.value,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    // Pre-fill some data if coming from auth
    final args = Get.arguments;
    if (args != null) {
      if (args['phoneNumber'] != null) {
        phoneNumber.value = args['phoneNumber'];
      }
      if (args['email'] != null) {
        // Email would be set from auth context
      }
      if (args['name'] != null) {
        final nameParts = args['name'].toString().split(' ');
        firstName.value = nameParts.isNotEmpty ? nameParts.first : '';
        lastName.value = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';
      }
    }
  }
}
