import 'package:flutter/material.dart';

class ShegabetTheme {
  // ShegaBet Color System - Premium Ethiopian Beauty Salon Brand

  // Primary Colors - Ethiopian Inspired
  static const Color ethiopianGold = Color(0xFFD4AF37); // Rich Ethiopian Gold
  static const Color deepRoyalPurple = Color(0xFF6B46C1); // Deep Royal Purple
  static const Color softRose = Color(0xFFFB7185); // Soft Rose Pink
  static const Color warmCream = Color(0xFFFEF7ED); // Warm Cream Background

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Deep Charcoal
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color textLight = Color(0xFF9CA3AF); // Light Gray
  static const Color textMuted = Color(0xFFD1D5DB); // Muted Gray

  // Extended Palette
  static const Color purpleLight = Color(0xFFA78BFA); // Light Purple
  static const Color purpleDark = Color(0xFF4C1D95); // Dark Purple
  static const Color roseLight = Color(0xFFFECACA); // Light Rose
  static const Color goldLight = Color(0xFFFDE68A); // Light Gold
  static const Color goldDark = Color(0xFFB45309); // Dark Gold
  static const Color creamDark = Color(0xFFF5E6D3); // Dark Cream

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Colors - Warm Tones
  static const Color neutral50 = Color(0xFFFEF7ED); // Warm Cream
  static const Color neutral100 = Color(0xFFF5E6D3); // Light Cream
  static const Color neutral200 = Color(0xFFE5D4B1); // Soft Beige
  static const Color neutral300 = Color(0xFFD4A574); // Light Brown
  static const Color neutral400 = Color(0xFFB8935F); // Medium Brown
  static const Color neutral500 = Color(0xFF9C7C47); // Brown
  static const Color neutral600 = Color(0xFF7A5C3A); // Dark Brown
  static const Color neutral700 = Color(0xFF5C4033); // Darker Brown
  static const Color neutral800 = Color(0xFF3E2723); // Darkest Brown

  // Gradients - Subtle and Premium
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepRoyalPurple, purpleLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [warmCream, neutral100],
    stops: [0.0, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, neutral50],
    stops: [0.0, 1.0],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ethiopianGold, goldLight],
    stops: [0.0, 1.0],
  );

  // Shadow System
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x1A000000), // 10% black
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x26000000), // 15% black
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  static const BoxShadow strongShadow = BoxShadow(
    color: Color(0x33000000), // 20% black
    blurRadius: 32,
    offset: Offset(0, 16),
  );

  // Typography System
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
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Button Styles
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: deepRoyalPurple,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button,
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: deepRoyalPurple,
    side: const BorderSide(color: deepRoyalPurple, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button.copyWith(color: deepRoyalPurple),
  );

  static ButtonStyle goldButton = ElevatedButton.styleFrom(
    backgroundColor: ethiopianGold,
    foregroundColor: textPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: button.copyWith(color: textPrimary),
  );

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [softShadow],
  );

  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [mediumShadow],
    border: Border.all(color: neutral200, width: 1),
  );

  // Input Decoration
  static InputDecorationTheme inputDecorationTheme = const InputDecorationTheme(
    filled: true,
    fillColor: neutral50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: neutral300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: neutral300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: deepRoyalPurple, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: error, width: 1),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(color: textLight, fontSize: 16),
    labelStyle: TextStyle(color: textSecondary, fontSize: 14),
  );

  // Complete Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: deepRoyalPurple,
        secondary: softRose,
        surface: Colors.white,
        error: error,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
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
          foregroundColor: deepRoyalPurple,
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
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: deepRoyalPurple,
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

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: deepRoyalPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: deepRoyalPurple,
        linearTrackColor: neutral300,
        circularTrackColor: neutral300,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return deepRoyalPurple;
          }
          return neutral400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return purpleLight.withValues(alpha: 0.3);
          }
          return neutral300;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return deepRoyalPurple;
          }
          return Colors.white;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return deepRoyalPurple;
          }
          return neutral400;
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: neutral300,
        thickness: 1,
        space: 1,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: heading4,
        contentTextStyle: bodyMedium,
      ),
    );
  }
}
