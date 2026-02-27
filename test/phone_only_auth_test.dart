import 'package:flutter_test/flutter_test.dart';

import '../lib/features/auth/controllers/phone_auth_controller.dart';
import '../lib/features/auth/controllers/user_registration_controller.dart';
import '../lib/routes/app_routes.dart';

void main() {
  group('Phone-Only Authentication Tests', () {
    test('App routes should only contain phone authentication', () {
      // Verify phone routes exist
      expect(AppRoutes.phoneAuth, '/auth/phone');
      expect(AppRoutes.otpVerification, '/auth/otp');
      expect(AppRoutes.userRegistration, '/auth/registration');
      expect(AppRoutes.authLanding, '/auth/landing');
    });

    test('Phone auth controller should handle sign up flow', () {
      final controller = PhoneAuthController();

      // Test initial state
      expect(controller.isSignUpMode.value, true);
      expect(controller.canProceed, false);

      // Set valid phone number
      controller.phoneNumber.value = '+254123456789';
      expect(controller.canProceed, true);

      // Test toggle
      controller.toggleMode();
      expect(controller.isSignUpMode.value, false);

      controller.toggleMode();
      expect(controller.isSignUpMode.value, true);
    });

    test('User registration should work with phone-only flow', () {
      final controller = UserRegistrationController();

      // Test that registration doesn't require email
      controller.setFirstName('John');
      controller.setLastName('Doe');
      controller.setPhoneNumber('+254123456789');
      controller.setLocation('Nairobi');
      controller.setGender('male');
      controller.setDateOfBirth('2000-01-01');
      controller.setHairType('Straight');
      controller.setSkinType('Normal');
      controller.togglePreferredService('Haircuts');

      expect(controller.canSubmit, true);

      // Test name combination
      final fullName =
          '${controller.firstName.value} ${controller.lastName.value}';
      expect(fullName, 'John Doe');
    });
  });
}
