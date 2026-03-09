import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize GetX and GetStorage
  await GetStorage.init();
  Get.put(GetStorage()); // Initialize LocalStorage
  // Note: GetProviders will be initialized when needed

  // Initialize dependencies
  await initializeDependencies();

  runApp(const ProviderScope(child: AfroProviderApp()));
}

class AfroProviderApp extends ConsumerWidget {
  const AfroProviderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          title: 'AFRO Provider',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
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
  }
}
