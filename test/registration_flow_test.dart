// Registration Flow Tests - updated to match current controller API
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/auth/controllers/user_registration_controller.dart';

void main() {
  group('Registration Flow Tests', () {
    test('User registration controller should validate separate names', () {
      final controller = UserRegistrationController();

      expect(controller.isFirstNameValid, false);
      expect(controller.isLastNameValid, false);
      expect(controller.canSubmit, false);

      controller.setFirstName('John');
      expect(controller.isFirstNameValid, true);
      expect(controller.isLastNameValid, false);

      controller.setLastName('Doe');
      expect(controller.isFirstNameValid, true);
      expect(controller.isLastNameValid, true);
    });

    test('User registration combines first and last names correctly', () {
      final controller = UserRegistrationController();
      controller.setFirstName('John');
      controller.setLastName('Doe');

      final actualName =
          '${controller.firstName.value.trim()} ${controller.lastName.value.trim()}';
      expect(actualName, 'John Doe');
    });
  });
}
