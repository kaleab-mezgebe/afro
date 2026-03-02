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
import '../features/home/bindings/portfolio_binding.dart';
import '../features/home/views/home_page.dart';
import '../features/home/views/portfolio_page.dart';
import '../features/onboarding/views/onboarding_page.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/profile/views/edit_profile_page.dart';
import '../features/profile/views/profile_page.dart';
import '../features/profile/views/settings_page.dart';
import '../features/search/views/search_page.dart' as search;
import '../features/splash/views/splash_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
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

    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(
      name: AppRoutes.portfolio,
      page: () {
        final specialist = Get.arguments as Map<String, dynamic>;
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
