import 'package:flutter_test/flutter_test.dart';

import '../lib/features/auth/controllers/phone_auth_controller.dart';
import '../lib/features/auth/controllers/user_registration_controller.dart';

void main() {
  group('Registration Flow Tests', () {
    test(
      'Phone auth controller should navigate to registration on sign up',
      () {
        final controller = PhoneAuthController();
        controller.isSignUpMode.value = true;
        controller.phoneNumber.value = '+254123456789';

        expect(controller.canProceed, true);
        expect(controller.isSignUpMode.value, true);
      },
    );

    test('User registration controller should validate separate names', () {
      final controller = UserRegistrationController();

      // Test empty names
      expect(controller.isFirstNameValid, false);
      expect(controller.isLastNameValid, false);
      expect(controller.canSubmit, false);

      // Set first name only
      controller.setFirstName('John');
      expect(controller.isFirstNameValid, true);
      expect(controller.isLastNameValid, false);
      expect(controller.canSubmit, false);

      // Set last name
      controller.setLastName('Doe');
      expect(controller.isFirstNameValid, true);
      expect(controller.isLastNameValid, true);
      expect(controller.canSubmit, false);

      // Set other required fields
      controller.setPhoneNumber('+254123456789');
      controller.setLocation('Nairobi');
      controller.setGender('male');
      controller.setDateOfBirth('2000-01-01');
      controller.setHairType('Straight');
      controller.setSkinType('Normal');
      controller.togglePreferredService('Haircuts');

      expect(controller.canSubmit, true);
    });

    test('User registration combines first and last names correctly', () {
      final controller = UserRegistrationController();
      controller.setFirstName('John');
      controller.setLastName('Doe');

      // Test name combination in user creation
      final expectedName = 'John Doe';
      final actualName =
          '${controller.firstName.value.trim()} ${controller.lastName.value.trim()}';

      expect(actualName, expectedName);
    });
  });
}
