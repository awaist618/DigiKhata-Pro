import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';

class AppTextStyles {
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? opacity,
  }) {
    TextStyle style = GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
    if (opacity != null) {
      style = style.copyWith(color: color?.withValues(alpha: opacity) ?? Colors.white.withValues(alpha: opacity));
    }
    return style;
  }

  // Specific Styles
  static TextStyle get welcomeTitle => poppins(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get welcomeSubtitle => poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.textSecondary,
      );

  static TextStyle get loginHeaderTitle => poppins(
        fontSize: 42,
        fontWeight: FontWeight.w800, // ExtraBold
        color: Colors.white,
      );

  static TextStyle get loginHeaderTagline => poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500, // Medium
        color: Colors.white,
        opacity: 0.9,
      );
}
