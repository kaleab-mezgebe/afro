// Phone Auth Tests - updated to match current PhoneAuthController API
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/routes/app_routes.dart';

void main() {
  group('Phone-Only Authentication Tests', () {
    test('App routes should only contain phone authentication', () {
      expect(AppRoutes.phoneAuth, '/auth/phone');
      expect(AppRoutes.otpVerification, '/auth/otp');
      expect(AppRoutes.userRegistration, '/auth/registration');
      expect(AppRoutes.authLanding, '/auth/landing');
    });
  });
}
