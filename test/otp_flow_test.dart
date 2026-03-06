// OTP Flow Tests - updated to match current PhoneAuthController API
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/auth/controllers/otp_verification_controller.dart';

void main() {
  group('OTP Authentication Flow Tests', () {
    test('OTP controller should handle otp validation', () {
      final controller = OTPVerificationController();

      // Test default values
      expect(controller.phoneNumber.value, '');

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
  });
}
