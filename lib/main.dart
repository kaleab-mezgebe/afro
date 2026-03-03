import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Customer App - Premium Barber Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialBinding: InitialBinding(),
          initialRoute: AppRoutes.splash,
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
