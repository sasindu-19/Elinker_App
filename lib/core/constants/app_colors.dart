// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (matching elinker.lk dark theme)
  static const Color primary = Color(0xFF00E5CC);       // Teal/Cyan
  static const Color primaryLight = Color(0xFF00FFE0);
  static const Color primaryDark = Color(0xFF00B4A0);
  static const Color secondary = Color(0xFF0066FF);     // Blue accent

  // Background Colors
  static const Color bgDark = Color(0xFF080C14);        // Darkest bg
  static const Color bgCard = Color(0xFF0E1421);        // Card bg
  static const Color bgSurface = Color(0xFF141B2D);     // Surface
  static const Color bgElevated = Color(0xFF1A2235);    // Elevated surface

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);
  static const Color textAccent = Color(0xFF00E5CC);

  // Status Colors
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF4D6A);
  static const Color info = Color(0xFF2196F3);

  // Border Colors
  static const Color borderDefault = Color(0xFF1E2A3E);
  static const Color borderAccent = Color(0xFF00E5CC);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5CC), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF080C14), Color(0xFF0E1421)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF050810), Color(0xFF0A1628), Color(0xFF060B18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Job Category Colors
  static const Color catTech = Color(0xFF00E5CC);
  static const Color catConstruction = Color(0xFFFF7043);
  static const Color catCreative = Color(0xFFAB47BC);
  static const Color catDelivery = Color(0xFF42A5F5);
  static const Color catDomestic = Color(0xFF66BB6A);
  static const Color catOther = Color(0xFFFFB300);
}
