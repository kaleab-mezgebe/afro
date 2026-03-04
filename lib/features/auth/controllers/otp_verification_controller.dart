import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/butter_theme.dart';
import '../../../routes/app_routes.dart';

class OTPVerificationController extends GetxController {
  late TextEditingController otpController;

  // Form fields
  final RxString otp = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString verificationId = ''.obs;
  int? resendToken;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
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
      error.value = '';

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp.value,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Get.snackbar(
          'Welcome!',
          'Successfully verified your phone number',
          backgroundColor: AppTheme.primaryYellow,
          colorText: AppTheme.black,
        );

        if (isSignUpMode.value) {
          Get.offNamed(
            AppRoutes.userRegistration,
            arguments: {'phoneNumber': phoneNumber.value},
          );
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        msg = 'Invalid OTP. Please check and try again.';
      } else if (e.code == 'session-expired') {
        msg = 'OTP has expired. Please request a new one.';
      } else if (e.code == 'invalid-verification-id') {
        msg = 'Session expired. Please go back and try again.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      error.value = msg;
      Get.snackbar(
        'Verification Failed',
        msg,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Verification Failed',
        e.toString(),
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
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
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          Get.offAllNamed(AppRoutes.home);
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        canResend.value = true;
        Get.snackbar(
          'Failed to Resend OTP',
          e.message ?? 'An error occurred',
          backgroundColor: ButterTheme.errorRose,
          colorText: Colors.white,
        );
      },

      codeSent: (String newVerificationId, int? newResendToken) {
        verificationId.value = newVerificationId;
        resendToken = newResendToken;
        _startCountdown();
        Get.snackbar(
          'OTP Resent!',
          'New verification code sent to ${phoneNumber.value}',
          backgroundColor: AppTheme.primaryYellow,
          colorText: AppTheme.black,
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
    error.value = '';
  }
}
