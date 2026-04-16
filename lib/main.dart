import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/bindings/initial_binding_enhanced.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/utils/logger.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch all Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.e('Flutter error: ${details.exception}');
    FlutterError.presentError(details);
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    AppLogger.e('Firebase initialization error: $e');
  }

  FirebaseMessagingService().initialize().catchError((e) {
    AppLogger.e('Firebase Messaging initialization error: $e');
  });

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
          initialBinding: InitialBindingEnhanced(),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          // Global unknown route handler
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const _NotFoundPage(),
          ),
          builder: (context, child) {
            // Global error boundary
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return _ErrorBoundaryWidget(details: details);
            };
            return SafeArea(top: false, child: child!);
          },
        );
      },
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 80,
              color: AppTheme.grey300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: TextStyle(color: AppTheme.grey500),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              style: AppTheme.primaryButton,
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBoundaryWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ErrorBoundaryWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 44,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected error occurred. Please try again.',
                style: TextStyle(color: AppTheme.grey500, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Return to Home'),
                style: AppTheme.primaryButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
