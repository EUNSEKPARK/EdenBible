import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// 프로젝트 에덴 테마 시스템
class EdenTheme {
  EdenTheme._();

  // ─── Light Theme ───
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Pretendard',
      colorScheme: const ColorScheme.light(
        primary: EdenColors.primary,
        onPrimary: Colors.white,
        secondary: EdenColors.secondary,
        onSecondary: Colors.white,
        tertiary: EdenColors.accent,
        surface: EdenColors.surfaceLight,
        onSurface: EdenColors.textPrimaryLight,
        surfaceContainerHighest: EdenColors.surfaceVariantLight,
        error: EdenColors.error,
      ),
      scaffoldBackgroundColor: EdenColors.backgroundLight,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: EdenColors.backgroundLight,
        foregroundColor: EdenColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: EdenColors.textPrimaryLight,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: EdenColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withValues(alpha:0.05),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: EdenColors.surfaceLight,
        selectedItemColor: EdenColors.primary,
        unselectedItemColor: EdenColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Text
      textTheme: _buildTextTheme(Brightness.light),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EdenColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(10),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EdenColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: EdenColors.textTertiaryLight,
          fontFamily: 'Pretendard',
          fontSize: 15,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: EdenColors.dividerLight,
        thickness: 0.5,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: EdenColors.surfaceVariantLight,
        selectedColor: EdenColors.primary.withValues(alpha:0.15),
        labelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }

  // ─── Dark Theme ───
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Pretendard',
      colorScheme: const ColorScheme.dark(
        primary: EdenColors.primaryLight,
        onPrimary: Colors.black,
        secondary: EdenColors.secondary,
        onSecondary: Colors.black,
        tertiary: EdenColors.accentLight,
        surface: EdenColors.surfaceDark,
        onSurface: EdenColors.textPrimaryDark,
        surfaceContainerHighest: EdenColors.surfaceVariantDark,
        error: EdenColors.error,
      ),
      scaffoldBackgroundColor: EdenColors.backgroundDark,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: EdenColors.backgroundDark,
        foregroundColor: EdenColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: EdenColors.textPrimaryDark,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: EdenColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: EdenColors.surfaceDark,
        selectedItemColor: EdenColors.primaryLight,
        unselectedItemColor: EdenColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Text
      textTheme: _buildTextTheme(Brightness.dark),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EdenColors.primaryLight,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(0, 44),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(10),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EdenColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: EdenColors.textTertiaryDark,
          fontFamily: 'Pretendard',
          fontSize: 15,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: EdenColors.dividerDark,
        thickness: 0.5,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: EdenColors.surfaceVariantDark,
        selectedColor: EdenColors.primaryLight.withValues(alpha:0.2),
        labelStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }

  // ─── Text Theme Builder ───
  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color primary = isLight ? EdenColors.textPrimaryLight : EdenColors.textPrimaryDark;
    final Color secondary = isLight ? EdenColors.textSecondaryLight : EdenColors.textSecondaryDark;

    return TextTheme(
      // Display
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary, height: 1.3),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, height: 1.3),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary, height: 1.3),

      // Headline
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary, height: 1.4),

      // Title
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary, height: 1.4),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary, height: 1.4),

      // Body (성경 본문에 최적화)
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: primary, height: 1.8, letterSpacing: 0.3),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.7),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.6),

      // Label
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: secondary),
    );
  }
}
