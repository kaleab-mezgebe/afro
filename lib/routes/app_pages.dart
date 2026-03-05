import 'package:get/get.dart';

import '../features/auth/bindings/phone_auth_binding.dart';
import '../features/auth/bindings/otp_verification_binding.dart';
import '../features/auth/bindings/user_registration_binding.dart';
import '../features/auth/views/phone_auth_page.dart';
import '../features/auth/views/otp_verification_page.dart';
import '../features/booking/bindings/booking_binding.dart';
import '../features/booking/views/booking_history_page.dart';
import '../features/booking/views/booking_service_page.dart';
import '../features/booking/views/booking_summary_page.dart';
import '../features/booking/views/booking_time_page.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/bindings/portfolio_binding.dart';
import '../features/home/views/home_page.dart';
import '../features/home/views/portfolio_page.dart';
import '../features/main/bindings/main_binding.dart';
import '../features/main/views/main_layout_page.dart';
import '../features/onboarding/views/onboarding_page.dart';
import '../features/preferences/views/preference_selection_page.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/profile/views/edit_profile_page.dart';
import '../features/profile/views/profile_page.dart';
import '../features/profile/views/settings_page.dart';
import '../features/search/views/search_page.dart' as search;

import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),
    GetPage(
      name: AppRoutes.phoneAuth,
      page: () => const PhoneAuthPage(),
      binding: PhoneAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationPage(),
      binding: OTPVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.preferenceSelection,
      page: () => const PreferenceSelectionPage(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const MainLayoutPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.portfolio,
      page: () {
        final arguments = Get.arguments;
        if (arguments == null) {
          // Return a default specialist if no arguments provided
          return PortfolioPage(
            specialist: {
              'id': 'default',
              'name': 'Default Specialist',
              'image': null,
              'rating': 4.5,
              'categories': ['Hairdressing'],
              'gender': 'female',
              'services': [],
              'portfolio': [],
              'reviews': [],
              'contact': {'phone': '', 'email': '', 'address': ''},
            },
          );
        }

        final specialist = arguments as Map<String, dynamic>?;
        if (specialist == null) {
          // Return a default specialist if arguments are not a Map
          return PortfolioPage(
            specialist: {
              'id': 'default',
              'name': 'Default Specialist',
              'image': null,
              'rating': 4.5,
              'categories': ['Hairdressing'],
              'gender': 'female',
              'services': [],
              'portfolio': [],
              'reviews': [],
              'contact': {'phone': '', 'email': '', 'address': ''},
            },
          );
        }

        return PortfolioPage(specialist: specialist);
      },
      binding: PortfolioBinding(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingService,
      page: () => const BookingServicePage(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingTime,
      page: () => const BookingTimePage(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingSummary,
      page: () => const BookingSummaryPage(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingHistory,
      page: () => const BookingHistoryPage(),
      binding: BookingBinding(),
    ),
    GetPage(name: AppRoutes.search, page: () => const search.SearchPage()),
  ];
}
