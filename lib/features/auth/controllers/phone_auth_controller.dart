import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/theme/butter_theme.dart';
import '../../../routes/app_routes.dart';

class PhoneAuthController extends GetxController {
  // Form fields
  final RxString phoneNumber = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isSignUpMode = true.obs; // Toggle between sign-in and sign-up

  // Text controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;

  // Country picker
  final Rx<Country> selectedCountry = Country(
    phoneCode: '251',
    countryCode: 'ET',
    name: 'Ethiopia',
    e164Sc: 251,
    geographic: true,
    level: 1,
    example: 'Ethiopia',
    displayName: 'Ethiopia (+251)',
    displayNameNoCountryCode: 'Ethiopia',
    e164Key: 'ET-251',
  ).obs;

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Validation
  bool get isPhoneNumberValid {
    final phone = phoneNumber.value.replaceAll(RegExp(r'[^\d]'), '');
    return phone.length >= 9 && phone.length <= 15;
  }

  bool get isEmailValid {
    return email.value.isNotEmpty &&
        email.value.contains('@') &&
        email.value.contains('.') &&
        email.value.length > 5;
  }

  bool get isPasswordValid {
    return password.value.length >= 6;
  }

  bool get canProceed => !isLoading.value;

  void setPhoneNumber(String value) {
    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    phoneNumber.value = cleanPhone;
  }

  void setEmail(String value) => email.value = value;
  void setPassword(String value) => password.value = value;

  void onCountryChanged(Country country) {
    selectedCountry.value = country;
  }

  void toggleMode() => isSignUpMode.value = !isSignUpMode.value;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    if (value.length < 5) {
      return 'Email is too short';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 9) {
      return 'Phone number is too short';
    }
    if (cleanPhone.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  Future<void> proceed() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Mock OTP sending - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));

      final fullPhoneNumber =
          '+${selectedCountry.value.phoneCode}${phoneNumber.value}';

      if (isSignUpMode.value) {
        // Navigate to user registration page (sign-up)
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {'phoneNumber': fullPhoneNumber, 'isSignUpMode': true},
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
          arguments: {'phoneNumber': fullPhoneNumber, 'isSignUpMode': false},
        );

        Get.snackbar(
          'OTP Sent!',
          'Verification code sent to $fullPhoneNumber',
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

  // Social login methods
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = '';

      // TODO: Implement actual Google Sign-In logic
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Google Sign-In',
        'Google sign-in functionality coming soon!',
        backgroundColor: ButterTheme.successMint,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Google Sign-In Failed',
        error.value,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      isLoading.value = true;
      error.value = '';

      // TODO: Implement actual Facebook Sign-In logic
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Facebook Sign-In',
        'Facebook sign-in functionality coming soon!',
        backgroundColor: ButterTheme.successMint,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Facebook Sign-In Failed',
        error.value,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
