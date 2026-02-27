import 'package:flutter/material.dart';

class ButterTheme {
  // Butter Color Palette - Soft, warm, and creamy
  static const Color primaryButter = Color(0xFFFFF8E1); // Soft butter yellow
  static const Color primaryCream = Color(0xFFFFF3C4); // Warm cream
  static const Color primaryGolden = Color(0xFFFFD54F); // Golden butter
  static const Color primaryAmber = Color(0xFFFFB300); // Deep amber
  static const Color primaryHoney = Color(0xFFFFA000); // Rich honey

  // Secondary Colors - Muted and elegant
  static const Color secondaryVanilla = Color(0xFFF5E6D3); // Vanilla cream
  static const Color secondaryLatte = Color(0xFFE8D5B7); // Coffee latte
  static const Color secondaryCaramel = Color(0xFFD4A574); // Caramel brown
  static const Color secondaryChocolate = Color(0xFF8B6914); // Dark chocolate

  // Neutral Colors - Warm grays and beiges
  static const Color neutralWarmWhite = Color(0xFFFEFEFE); // Warm white
  static const Color neutralLightCream = Color(0xFFF8F5F0); // Light cream
  static const Color neutralSoftGray = Color(0xFFE5E2DD); // Soft gray
  static const Color neutralWarmGray = Color(0xFFD4CFC7); // Warm gray
  static const Color neutralMediumGray = Color(0xFFA8A29E); // Medium gray
  static const Color neutralDarkGray = Color(0xFF57534E); // Dark gray
  static const Color neutralCharcoal = Color(0xFF2C2C2C); // Charcoal

  // Accent Colors - Soft pastels
  static const Color accentBlush = Color(0xFFFFE0E6); // Soft blush pink
  static const Color accentSage = Color(0xFFB8D4C3); // Sage green
  static const Color accentSky = Color(0xFFB8D4E8); // Soft sky blue
  static const Color accentLavender = Color(0xFFD4B8E8); // Soft lavender

  // Status Colors
  static const Color successMint = Color(0xFF6FCF97); // Soft mint green
  static const Color warningPeach = Color(0xFFFFB366); // Soft peach
  static const Color errorRose = Color(0xFFFF6B6B); // Soft rose red
  static const Color infoOcean = Color(0xFF4ECDC4); // Soft ocean blue

  // Text Colors
  static const Color textPrimary = neutralCharcoal;
  static const Color textSecondary = neutralDarkGray;
  static const Color textLight = neutralMediumGray;
  static const Color textMuted = neutralWarmGray;
  static const Color textOnPrimary = neutralCharcoal;

  // Gradients - Soft and buttery smooth
  static const LinearGradient primaryLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryButter, primaryCream, primaryGolden],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient secondaryLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryVanilla, secondaryLatte, secondaryCaramel],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlush, accentSage, accentSky],
    stops: [0.0, 0.5, 1.0],
  );

  // Butter Theme Data
  static ThemeData get butterTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryGolden,
        secondary: secondaryLatte,
        surface: neutralWarmWhite,
        background: neutralLightCream,
        error: errorRose,
        onPrimary: textOnPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: neutralWarmWhite,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 24),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGolden,
          foregroundColor: textOnPrimary,
          elevation: 0,
          shadowColor: primaryButter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGolden,
          side: const BorderSide(color: primaryGolden, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGolden,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralWarmWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neutralSoftGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neutralSoftGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGolden, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRose, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRose, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 16),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: neutralWarmWhite,
        elevation: 2,
        shadowColor: primaryButter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGolden,
        foregroundColor: textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neutralWarmWhite,
        selectedItemColor: primaryGolden,
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

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: neutralSoftGray,
        selectedColor: primaryGolden,
        disabledColor: neutralWarmGray,
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGolden,
        linearTrackColor: neutralSoftGray,
        circularTrackColor: neutralSoftGray,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGolden,
        inactiveTrackColor: neutralSoftGray,
        thumbColor: primaryGolden,
        overlayColor: primaryButter,
        valueIndicatorColor: primaryGolden,
        valueIndicatorTextStyle: const TextStyle(
          color: textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGolden;
          }
          return neutralWarmGray;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryButter;
          }
          return neutralSoftGray;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGolden;
          }
          return neutralWarmWhite;
        }),
        checkColor: MaterialStateProperty.all(textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGolden;
          }
          return neutralWarmGray;
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: neutralSoftGray,
        thickness: 1,
        space: 1,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: neutralCharcoal,
        contentTextStyle: const TextStyle(
          color: neutralWarmWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: neutralWarmWhite,
        elevation: 8,
        shadowColor: primaryButter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // Custom Butter Colors for specific use cases
  static const Color butterSurface = neutralLightCream;
  static const Color butterCard = neutralWarmWhite;
  static const Color butterBorder = neutralSoftGray;
  static const Color butterShadow = primaryButter;
  static const Color butterAccent = primaryGolden;
}
