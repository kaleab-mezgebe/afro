import 'package:flutter/material.dart';

class AppTheme {
  // Barber Shop Color System - White & Yellow Primary

  // Primary Colors
  static const Color primaryYellow = Color(
    0xFFFFB900,
  ); // Main Yellow from logo/buttons
  static const Color black = Color(0xFF000000); // Black for text and accents
  static const Color white = Color(0xFFFFFFFF); // Primary white background
  static const Color greyLight = Color(
    0xFFF8F8F8,
  ); // Very light grey for subtle contrast
  static const Color greyMedium = Color(
    0xFF9E9E9E,
  ); // Medium grey for disabled states
  static const Color greyDark = Color(
    0xFF424242,
  ); // Dark grey for secondary text

  // Text Colors
  static const Color textPrimary = black; // Primary text
  static const Color textSecondary = greyDark; // Secondary text
  static const Color textLight = greyMedium; // Light text
  static const Color textMuted = Color(0xFFBDBDBD); // Muted text
  static const Color textOnYellow = black; // Text on yellow backgrounds

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Success Green
  static const Color warning = Color(0xFFFF9800); // Warning Orange
  static const Color error = Color(0xFFF44336); // Error Red
  static const Color info = Color(0xFF2196F3); // Info Blue

  // Extended Palette - Yellow variations
  static const Color yellowLight = Color(0xFFFFF59D); // Light Yellow
  static const Color yellowDark = Color(0xFFF57F17); // Dark Yellow
  static const Color yellowPale = Color(0xFFFFF9C4); // Very pale yellow

  // Grey Scale - Complete range
  static const Color grey50 = Color(0xFFFAFAFA); // Very Light Grey
  static const Color grey100 = Color(0xFFF5F5F5); // Light Grey
  static const Color grey200 = Color(0xFFEEEEEE); // Lighter Grey
  static const Color grey300 = Color(0xFFE0E0E0); // Light-Medium Grey
  static const Color grey400 = Color(0xFFBDBDBD); // Medium Grey
  static const Color grey500 = Color(0xFF9E9E9E); // Medium-Dark Grey
  static const Color grey600 = Color(0xFF757575); // Dark Grey
  static const Color grey700 = Color(0xFF616161); // Darker Grey
  static const Color grey800 = Color(0xFF424242); // Very Dark Grey
  static const Color grey900 = Color(0xFF212121); // Almost Black

  // Gradients - Yellow focused
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, yellowLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [white, grey50],
    stops: [0.0, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, grey100],
    stops: [0.0, 1.0],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, yellowDark],
    stops: [0.0, 1.0],
  );

  // Shadow System - Subtle and clean
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x08000000), // 3% black - very subtle
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x12000000), // 7% black
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow strongShadow = BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Typography System - Clean and modern
  static const TextStyle heading1 = TextStyle(
    color: textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    color: textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle heading4 = TextStyle(
    color: textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    color: textOnYellow,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Button Styles - White & Yellow focused
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryYellow,
    foregroundColor: textOnYellow,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button,
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: primaryYellow,
    side: const BorderSide(color: primaryYellow, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button.copyWith(color: primaryYellow),
  );

  static ButtonStyle whiteButton = ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: primaryYellow,
    elevation: 0,
    shadowColor: Colors.transparent,
    side: const BorderSide(color: primaryYellow, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button.copyWith(color: primaryYellow),
  );

  // Card Styles - Clean white with subtle shadows
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [softShadow],
  );

  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [mediumShadow],
    border: Border.all(color: grey200, width: 1),
  );

  // Input Decoration - Yellow focus
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: grey50,
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: grey300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: grey300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: primaryYellow, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      borderSide: const BorderSide(color: error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: const TextStyle(color: textLight, fontSize: 16),
    labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
  );

  // Complete Theme Data - White & Yellow primary
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        secondary: primaryYellow,
        surface: white,
        background: white,
        error: error,
        onPrimary: textOnYellow,
        onSecondary: textOnYellow,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: white,
      ),

      // App Bar Theme - Clean white
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: heading4,
        iconTheme: IconThemeData(color: textPrimary, size: 24),
        centerTitle: true,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButton),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: inputDecorationTheme,

      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineLarge: heading4,
        headlineMedium: heading4,
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: caption,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Bottom Navigation Bar Theme - White with yellow accent
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryYellow,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme - Yellow
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: textOnYellow,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Progress Indicator Theme - Yellow
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryYellow,
        linearTrackColor: grey300,
        circularTrackColor: grey300,
      ),

      // Switch Theme - Yellow when active
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryYellow;
          }
          return grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return yellowLight.withOpacity(0.3);
          }
          return grey300;
        }),
      ),

      // Checkbox Theme - Yellow when checked
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryYellow;
          }
          return white;
        }),
        checkColor: WidgetStateProperty.all(textOnYellow),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme - Yellow when selected
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryYellow;
          }
          return grey400;
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grey300,
        thickness: 1,
        space: 1,
      ),

      // Snack Bar Theme - Black with white text
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Dialog Theme - White with yellow accents
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: heading4,
        contentTextStyle: bodyMedium,
      ),

      scaffoldBackgroundColor: AppTheme.white,
    );
  }
}
