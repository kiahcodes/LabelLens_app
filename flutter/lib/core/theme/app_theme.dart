// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppColors {
//   // Primary actions
//   static const green = Color(0xFF2E7D5E);
//   static const greenLight = Color(0xFFEFF7F3);
//   static const greenMid = Color(0xFF4CAF50);
//   static const amber = Color(0xFFD97706);
//   static const amberLight = Color(0xFFFEF3C7);
//   static const red = Color(0xFFDC2626);
//   static const redLight = Color(0xFFFEF2F2);

//   // Light theme — all white and very subtle
//   static const backgroundLight = Color(0xFFFFFFFF);
//   static const surfaceLight = Color(0xFFFFFFFF);
//   static const cardLight = Color(0xFFF9F9F9);
//   static const borderLight = Color(0xFFEEEEEE);
//   static const subtleLight = Color(0xFFF5F5F5);

//   // Dark theme
//   static const backgroundDark = Color(0xFF0F0F0F);
//   static const surfaceDark = Color(0xFF1A1A1A);
//   static const cardDark = Color(0xFF242424);
//   static const borderDark = Color(0xFF2E2E2E);
// }

// class AppTheme {
//   static TextTheme _buildTextTheme(Color primary, Color secondary) {
//     final base = GoogleFonts.plusJakartaSansTextTheme();
//     return base.copyWith(
//       displayLarge: base.displayLarge
//           ?.copyWith(color: primary, fontWeight: FontWeight.w700),
//       headlineMedium: base.headlineMedium
//           ?.copyWith(color: primary, fontWeight: FontWeight.w600, fontSize: 24),
//       headlineSmall: base.headlineSmall
//           ?.copyWith(color: primary, fontWeight: FontWeight.w600),
//       titleLarge: base.titleLarge
//           ?.copyWith(color: primary, fontWeight: FontWeight.w600),
//       titleMedium: base.titleMedium
//           ?.copyWith(color: primary, fontWeight: FontWeight.w500),
//       bodyLarge: base.bodyLarge?.copyWith(color: primary),
//       bodyMedium: base.bodyMedium?.copyWith(color: secondary),
//       bodySmall: base.bodySmall?.copyWith(color: secondary),
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
//           outline: AppColors.borderLight,
//         ),
//         textTheme: _buildTextTheme(
//           const Color(0xFF111111),
//           const Color(0xFF6B6B6B),
//         ),
//         cardTheme: CardThemeData(
//           color: AppColors.surfaceLight,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: const BorderSide(color: AppColors.borderLight),
//           ),
//           margin: EdgeInsets.zero,
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.backgroundLight,
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           centerTitle: false,
//           iconTheme: IconThemeData(color: Color(0xFF111111)),
//           titleTextStyle: TextStyle(
//             color: Color(0xFF111111),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         dividerTheme: const DividerThemeData(
//           color: AppColors.borderLight,
//           thickness: 1,
//           space: 1,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: AppColors.subtleLight,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.borderLight),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.borderLight),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.green, width: 1.5),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.red),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           labelStyle: const TextStyle(color: Color(0xFF6B6B6B)),
//           hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.green,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             textStyle:
//                 const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.green,
//             side: const BorderSide(color: AppColors.borderLight),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//           ),
//         ),
//         chipTheme: ChipThemeData(
//           backgroundColor: AppColors.subtleLight,
//           selectedColor: AppColors.greenLight,
//           side: const BorderSide(color: AppColors.borderLight),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           labelStyle: const TextStyle(fontSize: 13),
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: WidgetStateProperty.resolveWith((s) =>
//               s.contains(WidgetState.selected)
//                   ? AppColors.green
//                   : Colors.grey.shade400),
//           trackColor: WidgetStateProperty.resolveWith((s) =>
//               s.contains(WidgetState.selected)
//                   ? AppColors.greenLight
//                   : Colors.grey.shade200),
//         ),
//       );

//   static ThemeData get darkTheme => ThemeData(
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: AppColors.backgroundDark,
//         colorScheme: const ColorScheme.dark(
//           primary: AppColors.greenMid,
//           secondary: AppColors.amber,
//           error: AppColors.red,
//           surface: AppColors.surfaceDark,
//           outline: AppColors.borderDark,
//         ),
//         textTheme: _buildTextTheme(
//           const Color(0xFFF0F0F0),
//           const Color(0xFF888888),
//         ),
//         cardTheme: CardThemeData(
//           color: AppColors.cardDark,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: const BorderSide(color: AppColors.borderDark),
//           ),
//           margin: EdgeInsets.zero,
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.backgroundDark,
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           centerTitle: false,
//         ),
//         dividerTheme: const DividerThemeData(
//           color: AppColors.borderDark,
//           thickness: 1,
//           space: 1,
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: AppColors.cardDark,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.borderDark),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.borderDark),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.greenMid,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             padding: const EdgeInsets.symmetric(vertical: 14),
//           ),
//         ),
//       );
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DESIGN TOKENS ───────────────────────────────────────────────────────────

class AppColors {
  // Brand greens
  static const primary = Color(0xFF16A34A);
  static const primaryLight = Color(0xFF22C55E);
  static const primaryDark = Color(0xFF15803D);
  static const primarySurface = Color(0xFFF0FDF4);
  static const primaryBorder = Color(0xFFBBF7D0);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successSurface = Color(0xFFF0FDF4);
  static const warning = Color(0xFFF59E0B);
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const danger = Color(0xFFDC2626);
  static const dangerSurface = Color(0xFFFFF1F2);
  static const dangerBorder = Color(0xFFFFCDD2);

  // Verdict colors — richer tones
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFF0FDF4);
  static const greenMid = Color(0xFFDCFCE7);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFFFBEB);
  static const amberMid = Color(0xFFFEF3C7);
  static const red = Color(0xFFDC2626);
  static const redLight = Color(0xFFFFF1F2);
  static const redMid = Color(0xFFFFE4E6);

  // Neutrals — premium scale
  static const white = Color(0xFFFFFFFF);
  static const grey50 = Color(0xFFF8FAFC);
  static const grey100 = Color(0xFFF1F5F9);
  static const grey200 = Color(0xFFE2E8F0);
  static const grey300 = Color(0xFFCBD5E1);
  static const grey400 = Color(0xFF94A3B8);
  static const grey500 = Color(0xFF64748B);
  static const grey600 = Color(0xFF475569);
  static const grey700 = Color(0xFF334155);
  static const grey800 = Color(0xFF1E293B);
  static const grey900 = Color(0xFF0F172A);

  // Backgrounds
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFFFFF);

  // Borders
  static const borderLight = Color(0xFFE2E8F0);
  static const borderMid = Color(0xFFCBD5E1);

  // Gradient stops
  static const gradientStart = Color(0xFF16A34A);
  static const gradientEnd = Color(0xFF059669);

  // Legacy aliases — so existing code using these still compiles
  static const backgroundLight = background;
  static const surfaceLight = surface;
  static const cardLight = surface;
  static const subtleLight = grey50;
  static const borderLightAlias = borderLight;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 48.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const full = 999.0;
}

class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.02),
          blurRadius: 2,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.grey900.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get green => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

// ─── THEME ───────────────────────────────────────────────────────────────────

class AppTheme {
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    final inter = GoogleFonts.interTextTheme();
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: inter.displayMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      headlineMedium: inter.headlineMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        fontSize: 24,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        color: primaryColor,
        height: 1.6,
        letterSpacing: -0.1,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        color: secondaryColor,
        height: 1.6,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        color: secondaryColor,
        height: 1.5,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(
      AppColors.grey900,
      AppColors.grey500,
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.amber,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.grey900,
        outline: AppColors.borderLight,
        surfaceContainerHighest: AppColors.grey50,
      ),

      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.grey900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.grey700,
          size: 22,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.grey600,
          size: 22,
        ),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.grey200,
          disabledForegroundColor: AppColors.grey400,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.grey700,
          side: const BorderSide(color: AppColors.borderMid),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.grey500,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.grey400,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.inter(
          color: AppColors.danger,
          fontSize: 12,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.grey400,
        suffixIconColor: AppColors.grey400,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primaryBorder
                : AppColors.grey200),
        trackOutlineColor:
            WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primarySurface,
        disabledColor: AppColors.grey100,
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        checkmarkColor: AppColors.primary,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey400,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borderLight,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        elevation: 0,
        dragHandleColor: AppColors.grey300,
        dragHandleSize: Size(40, 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primarySurface,
        linearTrackColor: AppColors.primarySurface,
      ),

      // Float action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }

  // Keep dark theme minimal — app is light-only per requirements
  static ThemeData get darkTheme => lightTheme;
}

// ─── SHARED PREMIUM WIDGETS ───────────────────────────────────────────────────

/// Premium gradient button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? null
              : const LinearGradient(
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: onPressed == null ? AppColors.grey200 : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: onPressed == null ? [] : AppShadows.green,
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Premium card with shadow
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.elevated = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(AppRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: br,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: elevated ? AppShadows.md : AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: onTap != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: br,
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
                    child: child,
                  ),
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
                child: child,
              ),
      ),
    );
  }
}

/// Verdict badge pill
class VerdictPill extends StatelessWidget {
  final String verdict;
  final bool small;

  const VerdictPill({super.key, required this.verdict, this.small = false});

  Color get _bg {
    switch (verdict) {
      case 'GREEN':
        return AppColors.greenMid;
      case 'RED':
        return AppColors.redMid;
      default:
        return AppColors.amberMid;
    }
  }

  Color get _fg {
    switch (verdict) {
      case 'GREEN':
        return AppColors.green;
      case 'RED':
        return AppColors.red;
      default:
        return AppColors.amber;
    }
  }

  String get _label {
    switch (verdict) {
      case 'GREEN':
        return 'Safe';
      case 'RED':
        return 'Avoid';
      default:
        return 'Caution';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          color: _fg,
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(action!),
          ),
      ],
    );
  }
}
