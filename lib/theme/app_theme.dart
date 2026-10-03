import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GidiHomes visual language: deep Lagos green + warm gold, clean cards,
/// generous rounding. Works in light and dark.
class AppColors {
  static const green = Color(0xFF0B6B3A); // primary — Nigerian green
  static const greenDark = Color(0xFF07502B);
  static const greenSoft = Color(0xFFE6F3EC);
  static const gold = Color(0xFFF2A900); // accent — warm gold
  static const ink = Color(0xFF14201A);
  static const slate = Color(0xFF5B6B63);
  static const line = Color(0xFFE4E9E6);
  static const bg = Color(0xFFF7F9F8);
  static const surface = Colors.white;
  static const danger = Color(0xFFD64545);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.greenSoft,
        side: BorderSide.none,
        labelStyle: const TextStyle(
            color: AppColors.greenDark, fontWeight: FontWeight.w600),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(AppColors.line),
        enabledBorder: _inputBorder(AppColors.line),
        focusedBorder: _inputBorder(AppColors.green, width: 1.6),
        hintStyle: const TextStyle(color: AppColors.slate),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.green, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.slate,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: width),
      );
}
