import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/butter_theme.dart';
import '../../../core/utils/preference_helper.dart';
import '../../../routes/app_routes.dart';

class OTPVerificationController extends GetxController {
  late TextEditingController otpController;

  // Form fields
  final RxString otp = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString verificationId = ''.obs;
  int? resendToken;
  final RxBool isLoading = false.obs;
  final RxString validationError = ''.obs; // Only for validation errors
  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool isSignUpMode = false.obs;

  // Validation
  bool get isOTPValid => otp.value.length == 6;
  bool get canVerify => isOTPValid && !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    otpController = TextEditingController();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    phoneNumber.value = args['phoneNumber'] as String? ?? '';
    verificationId.value = args['verificationId'] as String? ?? '';
    resendToken = args['resendToken'] as int?;
    isSignUpMode.value = args['isSignUpMode'] as bool? ?? false;
    _startCountdown();
  }

  @override
  void onClose() {
    try {
      otpController.dispose();
    } catch (_) {}
    super.onClose();
  }

  void setOTP(String value) {
    otp.value = value;
  }

  Future<void> verifyOTP() async {
    if (otp.value.length != 6) return;

    try {
      isLoading.value = true;
      validationError.value = ''; // Clear validation errors

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp.value,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        Get.snackbar(
          'Success!',
          'Phone number verified successfully',
          backgroundColor: AppTheme.primaryYellow,
          colorText: AppTheme.black,
          duration: const Duration(seconds: 2),
        );

        if (isSignUpMode.value) {
          Get.offNamed(
            AppRoutes.userRegistration,
            arguments: {'phoneNumber': phoneNumber.value},
          );
        } else {
          await PreferenceHelper.navigateAfterAuth();
        }
      }
    } on FirebaseAuthException catch (e) {
      String userFriendlyMsg;

      if (e.code == 'invalid-verification-code') {
        userFriendlyMsg = 'Incorrect code. Please check and try again.';
        validationError.value =
            userFriendlyMsg; // Show in field for validation errors
      } else if (e.code == 'session-expired') {
        userFriendlyMsg = 'Code has expired. Please request a new one.';
      } else if (e.code == 'invalid-verification-id') {
        userFriendlyMsg = 'Session expired. Please go back and try again.';
      } else if (e.code == 'network-request-failed') {
        userFriendlyMsg =
            'Please check your internet connection and try again.';
      } else {
        userFriendlyMsg = _getUserFriendlyErrorMessage(e.message ?? e.code);
      }

      Get.snackbar(
        'Verification Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final userFriendlyMsg = _getUserFriendlyErrorMessage(e.toString());
      Get.snackbar(
        'Verification Failed',
        userFriendlyMsg,
        backgroundColor: ButterTheme.errorRose,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value) return;

    canResend.value = false;
    countdown.value = 60;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber.value,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,

      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        if (userCredential.user != null) {
          await PreferenceHelper.navigateAfterAuth();
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        canResend.value = true;
        String userFriendlyMsg;

        if (e.code == 'too-many-requests') {
          userFriendlyMsg =
              'Too many attempts. Please wait a few minutes and try again.';
        } else if (e.code == 'network-request-failed') {
          userFriendlyMsg =
              'Please check your internet connection and try again.';
        } else {
          userFriendlyMsg = _getUserFriendlyErrorMessage(
            e.message ?? 'Failed to resend code',
          );
        }

        Get.snackbar(
          'Unable to Resend Code',
          userFriendlyMsg,
          backgroundColor: ButterTheme.errorRose,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },

      codeSent: (String newVerificationId, int? newResendToken) {
        verificationId.value = newVerificationId;
        resendToken = newResendToken;
        _startCountdown();
        Get.snackbar(
          'Code Sent!',
          'New verification code sent to your phone',
          backgroundColor: AppTheme.primaryYellow,
          colorText: AppTheme.black,
          duration: const Duration(seconds: 3),
        );
      },

      codeAutoRetrievalTimeout: (_) {},
    );
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        if (countdown.value > 0) {
          countdown.value--;
          _startCountdown();
        } else {
          canResend.value = true;
        }
      }
    });
  }

  void clearError() {
    validationError.value = '';
  }

  /// Convert technical error messages to user-friendly messages
  String _getUserFriendlyErrorMessage(String technicalError) {
    final lowerError = technicalError.toLowerCase();

    // Network-related errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unreachable')) {
      return 'Please check your internet connection and try again.';
    }

    // Firebase-specific errors
    if (lowerError.contains('firebase') || lowerError.contains('auth')) {
      return 'Verification service is temporarily unavailable. Please try again.';
    }

    // Generic fallback for unknown errors
    return 'Something went wrong. Please try again.';
  }
}
