// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppColors {
//   static const green = Color(0xFF4CAF50);
//   static const greenLight = Color(0xFFE8F5E9);
//   static const amber = Color(0xFFFF9800);
//   static const amberLight = Color(0xFFFFF3E0);
//   static const red = Color(0xFFE53935);
//   static const redLight = Color(0xFFFFEBEE);

//   // Light theme
//   static const backgroundLight = Color(0xFFFAFAF8);
//   static const surfaceLight = Color(0xFFFFFFFF);
//   static const cardLight = Color(0xFFF5F4F0);

//   // Dark theme
//   static const backgroundDark = Color(0xFF1A1A2E);
//   static const surfaceDark = Color(0xFF16213E);
//   static const cardDark = Color(0xFF0F3460);
// }

// class AppTheme {
//   static TextTheme _buildTextTheme(Color primary, Color secondary) {
//     final base = GoogleFonts.plusJakartaSansTextTheme();
//     return base.copyWith(
//       displayLarge: base.displayLarge
//           ?.copyWith(color: primary, fontWeight: FontWeight.w700),
//       headlineMedium: base.headlineMedium
//           ?.copyWith(color: primary, fontWeight: FontWeight.w600),
//       titleLarge: base.titleLarge
//           ?.copyWith(color: primary, fontWeight: FontWeight.w600),
//       bodyLarge: base.bodyLarge?.copyWith(color: primary),
//       bodyMedium: base.bodyMedium?.copyWith(color: secondary),
//       labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
//     );
//   }

//   static ThemeData get lightTheme => ThemeData(
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: AppColors.backgroundLight,
//         colorScheme: const ColorScheme.light(
//           primary: AppColors.green,
//           secondary: AppColors.amber,
//           error: AppColors.red,
//           surface: AppColors.surfaceLight,
//         ),
//         textTheme: _buildTextTheme(
//           const Color(0xFF1A1A1A),
//           const Color(0xFF555555),
//         ),
//         cardTheme: CardThemeData(
//           color: AppColors.surfaceLight,
//           elevation: 0,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.backgroundLight,
//           elevation: 0,
//           centerTitle: false,
//           iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
//         ),
//       );

//   static ThemeData get darkTheme => ThemeData(
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: AppColors.backgroundDark,
//         colorScheme: const ColorScheme.dark(
//           primary: AppColors.green,
//           secondary: AppColors.amber,
//           error: AppColors.red,
//           surface: AppColors.surfaceDark,
//         ),
//         textTheme: _buildTextTheme(
//           const Color(0xFFF0F0F0),
//           const Color(0xFFAAAAAA),
//         ),
//         cardTheme: CardThemeData(
//           color: AppColors.surfaceDark,
//           elevation: 0,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.backgroundDark,
//           elevation: 0,
//           centerTitle: false,
//         ),
//       );
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary actions
  static const green = Color(0xFF2E7D5E);
  static const greenLight = Color(0xFFEFF7F3);
  static const greenMid = Color(0xFF4CAF50);
  static const amber = Color(0xFFD97706);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFEF2F2);

  // Light theme — all white and very subtle
  static const backgroundLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFF9F9F9);
  static const borderLight = Color(0xFFEEEEEE);
  static const subtleLight = Color(0xFFF5F5F5);

  // Dark theme
  static const backgroundDark = Color(0xFF0F0F0F);
  static const surfaceDark = Color(0xFF1A1A1A);
  static const cardDark = Color(0xFF242424);
  static const borderDark = Color(0xFF2E2E2E);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge
          ?.copyWith(color: primary, fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium
          ?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 24),
      headlineSmall: base.headlineSmall
          ?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge
          ?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium
          ?.copyWith(color: primary, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      bodySmall: base.bodySmall?.copyWith(color: secondary),
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
          outline: AppColors.borderLight,
        ),
        textTheme: _buildTextTheme(
          const Color(0xFF111111),
          const Color(0xFF6B6B6B),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF111111)),
          titleTextStyle: TextStyle(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.subtleLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.red),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: Color(0xFF6B6B6B)),
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.green,
            side: const BorderSide(color: AppColors.borderLight),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.subtleLight,
          selectedColor: AppColors.greenLight,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(fontSize: 13),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.green
                  : Colors.grey.shade400),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.greenLight
                  : Colors.grey.shade200),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.greenMid,
          secondary: AppColors.amber,
          error: AppColors.red,
          surface: AppColors.surfaceDark,
          outline: AppColors.borderDark,
        ),
        textTheme: _buildTextTheme(
          const Color(0xFFF0F0F0),
          const Color(0xFF888888),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenMid,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
}
