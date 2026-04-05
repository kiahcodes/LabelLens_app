import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const green = Color(0xFF4CAF50);
  static const greenLight = Color(0xFFE8F5E9);
  static const amber = Color(0xFFFF9800);
  static const amberLight = Color(0xFFFFF3E0);
  static const red = Color(0xFFE53935);
  static const redLight = Color(0xFFFFEBEE);

  // Light theme
  static const backgroundLight = Color(0xFFFAFAF8);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFF5F4F0);

  // Dark theme
  static const backgroundDark = Color(0xFF1A1A2E);
  static const surfaceDark = Color(0xFF16213E);
  static const cardDark = Color(0xFF0F3460);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge
          ?.copyWith(color: primary, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium
          ?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge
          ?.copyWith(color: primary, fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.amber,
          error: AppColors.red,
          surface: AppColors.surfaceLight,
        ),
        textTheme: _buildTextTheme(
          const Color(0xFF1A1A1A),
          const Color(0xFF555555),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceLight,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.amber,
          error: AppColors.red,
          surface: AppColors.surfaceDark,
        ),
        textTheme: _buildTextTheme(
          const Color(0xFFF0F0F0),
          const Color(0xFFAAAAAA),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          centerTitle: false,
        ),
      );
}
