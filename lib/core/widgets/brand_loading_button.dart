import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/afro_theme.dart';

/// A beautiful, reusable circular loading button with brand colors
class BrandLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const BrandLoadingButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main button
        Container(
          width: width ?? double.infinity,
          height: height ?? 56,
          decoration: BoxDecoration(
            color: backgroundColor ?? AfroTheme.primaryColor,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: textColor ?? AfroTheme.textPrimary,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.w600,
                color: textColor ?? AfroTheme.textPrimary,
              ),
            ),
          ),
        ),

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: (backgroundColor ?? AfroTheme.primaryColor).withOpacity(
                  0.9,
                ),
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
              child: Center(child: _buildBrandLoader()),
            ),
          ),
      ],
    );
  }

  Widget _buildBrandLoader() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AfroTheme.primaryColor),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// A floating brand loading indicator for overlay use
class BrandLoadingOverlay extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;

  const BrandLoadingOverlay({
    Key? key,
    this.message = 'Loading...',
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (backgroundColor ?? Colors.black).withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBrandLoader(),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AfroTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLoader() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AfroTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AfroTheme.primaryColor),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// A compact brand loading indicator
class CompactBrandLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CompactBrandLoader({Key? key, this.size = 24, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AfroTheme.primaryColor,
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

/// A brand loading button specifically for social login with icon
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconAssetPath;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;

  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.iconAssetPath,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main button
        Container(
          width: width ?? double.infinity,
          height: height ?? 56,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: textColor ?? Colors.black87,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                SvgPicture.asset(iconAssetPath, width: 24, height: 24),
                const SizedBox(width: 12),
                // Text
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 14,
                    fontWeight: fontWeight ?? FontWeight.w600,
                    color: textColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
