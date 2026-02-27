import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class OTPVerificationController extends GetxController {
  final TextEditingController otpController = TextEditingController();

  // Form fields
  final RxString otp = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool isSignUpMode = false.obs; // Track if this is sign-up flow

  // Validation
  bool get isOTPValid => otp.value.length == 6;
  bool get canVerify => isOTPValid && !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Get phone number and mode from arguments
    final args = Get.arguments;
    phoneNumber.value = args['phoneNumber'] as String? ?? '';
    isSignUpMode.value = args['isSignUpMode'] as bool? ?? false;
    _startCountdown();
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  void setOTP(String value) => otp.value = value;

  Future<void> verifyOTP() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Mock OTP verification - replace with actual implementation
      await Future.delayed(const Duration(seconds: 2));

      // For demo, accept "123456" as valid OTP
      if (otp.value != '123456') {
        throw Exception('Invalid OTP. Please try again.');
      }

      // Handle successful verification
      Get.snackbar(
        'Welcome!',
        'Successfully verified your phone number',
        backgroundColor: AppTheme.primaryYellow,
        colorText: AppTheme.black,
      );

      // Navigate based on sign-in vs sign-up mode
      if (isSignUpMode.value) {
        // Navigate to registration page for sign-up
        Get.offNamed(
          AppRoutes.userRegistration,
          arguments: {'phoneNumber': phoneNumber.value},
        );
      } else {
        // Navigate to home page for sign-in
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Verification Failed',
        error.value,
        backgroundColor: AppTheme.grey300,
        colorText: AppTheme.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resendOTP() async {
    try {
      // Mock resend OTP - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'OTP Resent!',
        'New verification code sent to ${phoneNumber.value}',
        backgroundColor: AppTheme.primaryYellow,
        colorText: AppTheme.black,
      );

      // Reset countdown
      canResend.value = false;
      countdown.value = 60;
      _startCountdown();
    } catch (e) {
      Get.snackbar(
        'Failed to Resend OTP',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (countdown.value > 0) {
        countdown.value--;
        _startCountdown();
      } else {
        canResend.value = true;
      }
    });
  }

  void clearError() {
    error.value = '';
  }
}
