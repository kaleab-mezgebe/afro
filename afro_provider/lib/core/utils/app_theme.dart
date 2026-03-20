import 'package:flutter/material.dart';

class AppTheme {
  // Barber Shop Color System - Modern White & Yellow Primary
  
  // Primary Colors
  static const Color primaryYellow = Color(0xFFFFB900); // Main Yellow from logo/buttons
  static const Color black = Color(0xFF000000); // Black for text and accents
  static const Color white = Color(0xFFFFFFFF); // Primary white background
  static const Color greyLight = Color(0xFFF8F8F8); // Very light grey
  static const Color greyMedium = Color(0xFF9E9E9E); // Medium grey
  static const Color greyDark = Color(0xFF424242); // Dark grey
  
  // Backward compatibility alias
  static const Color primaryGreen = primaryYellow; // Redirect Green to Yellow for consistency
  static const Color surfaceColor = white;
  static const Color textPrimary = black;
  static const Color textSecondary = greyDark;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, Color(0xFFFFD54F)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [black, greyDark],
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: primaryYellow,
        onPrimary: black,
        secondary: black,
        onSecondary: white,
        surface: white,
        error: error,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: black, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(color: black, fontSize: 16),
        bodyMedium: TextStyle(color: greyDark, fontSize: 14),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        brightness: Brightness.dark,
        primary: primaryYellow,
        onPrimary: black,
        surface: const Color(0xFF121212),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
    );
  }
}
