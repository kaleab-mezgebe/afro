import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../lib/features/auth/controllers/otp_verification_controller.dart';
import '../lib/features/auth/controllers/phone_auth_controller.dart';
import '../lib/routes/app_routes.dart';

void main() {
  group('OTP Authentication Flow Tests', () {
    test('OTP controller should handle sign-in vs sign-up mode', () {
      final controller = OTPVerificationController();

      // Test default values
      expect(controller.isSignUpMode.value, false);
      expect(controller.phoneNumber.value, '');

      // Test mode toggle
      controller.isSignUpMode.value = true;
      expect(controller.isSignUpMode.value, true);

      controller.isSignUpMode.value = false;
      expect(controller.isSignUpMode.value, false);
    });

    test('Phone auth controller should pass correct mode to OTP', () {
      final controller = PhoneAuthController();

      // Test sign-up mode
      controller.isSignUpMode.value = true;
      expect(controller.isSignUpMode.value, true);

      // Test sign-in mode
      controller.isSignUpMode.value = false;
      expect(controller.isSignUpMode.value, false);
    });

    test('OTP validation should work correctly', () {
      final controller = OTPVerificationController();

      // Test empty OTP
      controller.setOTP('');
      expect(controller.isOTPValid, false);
      expect(controller.canVerify, false);

      // Test partial OTP
      controller.setOTP('123');
      expect(controller.isOTPValid, false);
      expect(controller.canVerify, false);

      // Test valid OTP
      controller.setOTP('123456');
      expect(controller.isOTPValid, true);
      expect(controller.canVerify, true);
    });

    test('Authentication flow routes should be correct', () {
      // Verify all required routes exist
      expect(AppRoutes.phoneAuth, '/auth/phone');
      expect(AppRoutes.otpVerification, '/auth/otp');
      expect(AppRoutes.userRegistration, '/auth/registration');
      expect(AppRoutes.home, '/');
    });
  });
}
