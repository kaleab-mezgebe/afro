import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Determine initial route based on onboarding preference
  String initialRoute = AppRoutes.onboarding;
  try {
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('show_onboarding') ?? true;
    if (!showOnboarding) {
      initialRoute = AppRoutes.phoneAuth;
    }
  } catch (e) {
    debugPrint('Error loading preferences: $e');
  }

  runApp(CustomerApp(initialRoute: initialRoute));
}

class CustomerApp extends StatelessWidget {
  final String initialRoute;
  const CustomerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Customer App - Premium Barber Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: InitialBinding(),
          initialRoute: initialRoute,
          getPages: AppPages.pages,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),

          builder: (context, child) {
            return SafeArea(top: false, child: child!);
          },
        );
      },
    );
  }
}
