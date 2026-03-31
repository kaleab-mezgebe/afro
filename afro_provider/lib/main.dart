import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/utils/modern_theme.dart';
import 'core/screens/splash_screen.dart';
import 'core/services/notification_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting app initialization...');

  // Minimum splash screen display time (1 second)
  await Future.delayed(const Duration(seconds: 1));

  // Initialize GetX and GetStorage
  try {
    await GetStorage.init();
    Get.put(GetStorage()); // Initialize LocalStorage
    print('✅ GetStorage initialized');
  } catch (e) {
    print('⚠️ GetStorage initialization failed: $e');
  }

  // Initialize dependencies with error handling
  try {
    await initializeDependencies();
    print('✅ Dependencies initialized');
  } catch (e) {
    print('⚠️ Dependencies initialization failed: $e');
    print('App will continue with limited functionality');
  }

  print('🚀 App initialization complete');
}

void main() {
  runApp(const ProviderScope(child: AfroProviderApp()));
}

class AfroProviderApp extends ConsumerStatefulWidget {
  const AfroProviderApp({super.key});

  @override
  ConsumerState<AfroProviderApp> createState() => _AfroProviderAppState();
}

class _AfroProviderAppState extends ConsumerState<AfroProviderApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          print('Initialization error: ${snapshot.error}');
          // Still show the app even if initialization failed
        }

        return Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              title: 'AFRO Provider',
              debugShowCheckedModeBanner: false,
              theme: ModernTheme.lightTheme,
              darkTheme: ModernTheme.darkTheme,
              themeMode: ThemeMode.light,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                // Store context globally for notifications
                NotificationService.setContext(context);
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor:
                        MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
