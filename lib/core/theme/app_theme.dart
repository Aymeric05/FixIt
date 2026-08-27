import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixit/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryOrange,
      ),
      textTheme: GoogleFonts.luckiestGuyTextTheme(),
    );
  }
}
