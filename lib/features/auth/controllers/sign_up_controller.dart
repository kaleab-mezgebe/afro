import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/theme/app_theme.dart';

class SignUpController extends GetxController {
  // Form fields
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString dateOfBirth = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Country picker
  final Rx<Country> selectedCountry = Country(
    phoneCode: '254',
    countryCode: 'KE',
    name: 'Kenya',
    e164Sc: 254,
    geographic: true,
    level: 1,
    example: 'Kenya',
    displayName: 'Kenya (+254)',
    displayNameNoCountryCode: 'Kenya',
    e164Key: 'KE-254',
  ).obs;

  // Form validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Validation
  bool get isFirstNameValid => firstName.value.length >= 2;
  bool get isLastNameValid => lastName.value.length >= 2;
  bool get isEmailValid =>
      email.value.isNotEmpty &&
      email.value.contains('@') &&
      email.value.contains('.') &&
      email.value.length > 5;
  bool get isPhoneValid {
    final phone = phoneNumber.value.replaceAll(RegExp(r'[^\d]'), '');
    return phone.length >= 9 && phone.length <= 15;
  }

  bool get isPasswordValid => password.value.length >= 6;
  bool get isDateValid => dateOfBirth.value.isNotEmpty;

  bool get canProceed =>
      isFirstNameValid &&
      isLastNameValid &&
      isEmailValid &&
      isPhoneValid &&
      isPasswordValid &&
      isDateValid &&
      !isLoading.value;

  void setFirstName(String value) => firstName.value = value;
  void setLastName(String value) => lastName.value = value;
  void setEmail(String value) => email.value = value;
  void setDateOfBirth(String value) => dateOfBirth.value = value;
  void setPhoneNumber(String value) {
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    phoneNumber.value = cleanPhone;
  }

  void setPassword(String value) => password.value = value;

  void onCountryChanged(Country country) {
    selectedCountry.value = country;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

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

  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> register() async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;
      error.value = '';

      // Mock registration - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Account Created!',
        'Welcome to AFRO, ${firstName.value} ${lastName.value}!',
        backgroundColor: AppTheme.primaryYellow,
        colorText: AppTheme.black,
      );

      // Navigate to home page or onboarding
      Get.offAllNamed('/'); // Navigate to home/main page
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        error.value,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }

  void goToLogin() {
    Get.back();
  }
}
