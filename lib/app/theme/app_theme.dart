import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final outfitFont = GoogleFonts.outfit();
    final monoFont = GoogleFonts.jetBrainsMono();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.violet,
        surface: AppColors.surface,
        background: AppColors.canvas,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      fontFamily: outfitFont.fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: outfitFont.fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.68,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontFamily: outfitFont.fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.48,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontFamily: outfitFont.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: outfitFont.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: outfitFont.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.faint,
          fontFamily: monoFont.fontFamily,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cta, // Brand Coral CTA
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999), // Fully rounded pill
          ),
          textStyle: TextStyle(
            fontFamily: outfitFont.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.16,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false, // No container background for frameless inputs
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.faint, width: 1.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.faint, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.violet, width: 2.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 2.5),
        ),
        labelStyle: TextStyle(
          fontFamily: monoFont.fontFamily,
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: monoFont.fontFamily,
          color: AppColors.cta, // upper/floating labels in brand Coral or violet
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        hintStyle: TextStyle(
          fontFamily: outfitFont.fontFamily,
          color: AppColors.faint,
          fontSize: 16,
        ),
      ),
    );
  }
}
