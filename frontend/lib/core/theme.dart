import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E7D5B);
  static const dark = Color(0xFF14352A);
  static const accent = Color(0xFFF2A33A);
  static const bg = Color(0xFFF5F7F4);
  static const text = Color(0xFF1B2A24);
  static const muted = Color(0xFF6B7A73);
  static const border = Color(0xFFE3E8E4);
  static const tint = Color(0xFFE6F2EC);
  static const danger = Color(0xFFD9534F);
  static const info = Color(0xFF3B82C4);
  static const purple = Color(0xFF8A5CC9);
}

class AppText {
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text);
  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
  static const body = TextStyle(fontSize: 14, color: AppColors.text);
  static const small = TextStyle(fontSize: 12, color: AppColors.muted);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
      );
}
