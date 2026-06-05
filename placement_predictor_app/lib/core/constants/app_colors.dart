import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF1E6091);
  static const Color secondaryLight = Color(0xFF1A759F);
  static const Color accentLight = Color(0xFF52B788);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF1A759F);
  static const Color secondaryDark = Color(0xFF1E6091);
  static const Color accentDark = Color(0xFF52B788);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Common Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color failure = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  // Sleek Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E6091), Color(0xFF1A759F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
