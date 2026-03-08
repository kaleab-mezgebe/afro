import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Responsive utility class for handling different screen sizes
/// Uses Sizer package for adaptive sizing
class ResponsiveUtils {
  /// Check if device is mobile (width < 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if device is tablet (width >= 600dp and < 1024dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  /// Check if device is desktop (width >= 1024dp)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  /// Get responsive value based on screen size
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h);
    }
    return EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h);
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(horizontal: 10.w);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 6.w);
    }
    return EdgeInsets.symmetric(horizontal: 4.w);
  }

  /// Get responsive vertical padding
  static EdgeInsets responsiveVerticalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(vertical: 3.h);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(vertical: 2.h);
    }
    return EdgeInsets.symmetric(vertical: 2.h);
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSp) {
    if (isDesktop(context)) {
      return baseSp * 0.9;
    } else if (isTablet(context)) {
      return baseSp * 0.95;
    }
    return baseSp;
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSp) {
    if (isDesktop(context)) {
      return baseSp * 0.85;
    } else if (isTablet(context)) {
      return baseSp * 0.9;
    }
    return baseSp;
  }

  /// Get number of grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    }
    return 2;
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, {double multiplier = 1.0}) {
    if (isDesktop(context)) {
      return 2.h * multiplier;
    } else if (isTablet(context)) {
      return 1.5.h * multiplier;
    }
    return 1.h * multiplier;
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context, {double base = 12}) {
    if (isDesktop(context)) {
      return base * 1.2;
    } else if (isTablet(context)) {
      return base * 1.1;
    }
    return base;
  }

  /// Get responsive card elevation
  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) {
      return 4.0;
    } else if (isTablet(context)) {
      return 3.0;
    }
    return 2.0;
  }

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    }
    return double.infinity;
  }

  /// Get responsive list tile height
  static double getListTileHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 8.h;
    } else if (isTablet(context)) {
      return 9.h;
    }
    return 10.h;
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 6.h;
    } else if (isTablet(context)) {
      return 6.5.h;
    }
    return 7.h;
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 7.h;
    } else if (isTablet(context)) {
      return 7.5.h;
    }
    return 8.h;
  }

  /// Get orientation-based layout
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get screen width percentage
  static double widthPercent(double percent) {
    return percent.w;
  }

  /// Get screen height percentage
  static double heightPercent(double percent) {
    return percent.h;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Limit text scale factor to prevent UI breaking
    return textScaleFactor.clamp(0.8, 1.3);
  }
}

/// Extension on BuildContext for easier access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  
  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);
  EdgeInsets get responsiveHPadding => ResponsiveUtils.responsiveHorizontalPadding(this);
  EdgeInsets get responsiveVPadding => ResponsiveUtils.responsiveVerticalPadding(this);
  
  int get gridColumns => ResponsiveUtils.getGridColumns(this);
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);
  double get buttonHeight => ResponsiveUtils.getButtonHeight(this);
  double get appBarHeight => ResponsiveUtils.getAppBarHeight(this);
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) =>
      ResponsiveUtils.responsive(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
