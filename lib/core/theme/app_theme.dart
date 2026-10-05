// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
          headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
          labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: AppColors.borderDefault, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgElevated,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
