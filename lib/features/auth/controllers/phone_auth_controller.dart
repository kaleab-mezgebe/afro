import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/butter_theme.dart';
import '../../../routes/app_routes.dart';

class PhoneAuthController extends GetxController {
  // Form fields
  final RxString phoneNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isSignUpMode = true.obs; // Toggle between sign-in and sign-up

  // Validation
  bool get isPhoneNumberValid =>
      phoneNumber.value.length >= 10 && phoneNumber.value.startsWith('+');
  bool get canProceed => isPhoneNumberValid && !isLoading.value;

  void setPhoneNumber(String value) => phoneNumber.value = value;

  void toggleMode() => isSignUpMode.value = !isSignUpMode.value;

  Future<void> proceed() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Mock OTP sending - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));

      if (isSignUpMode.value) {
        // Navigate to user registration page (sign-up)
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {'phoneNumber': phoneNumber.value, 'isSignUpMode': true},
        );

        Get.snackbar(
          'Phone Number Verified!',
          'Complete your profile to continue',
          backgroundColor: ButterTheme.successMint,
          colorText: Colors.white,
        );
      } else {
        // Navigate to OTP verification page (sign-in)
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {'phoneNumber': phoneNumber.value, 'isSignUpMode': false},
        );

        Get.snackbar(
          'OTP Sent!',
          'Verification code sent to ${phoneNumber.value}',
          backgroundColor: ButterTheme.successMint,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Failed to Send OTP',
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
}
