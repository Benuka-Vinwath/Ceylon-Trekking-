import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1F4D36); // forest green: selected chips, secondary buttons, icons
  static const dark = Color(0xFF13261C); // dark screens (splash, login, home header)
  static const darkCard = Color(0xFF1E3A2B); // cards and fields on dark screens
  static const accent = Color(0xFFF07A1A); // orange: main call-to-action buttons
  static const star = Color(0xFFF5A623);
  static const bg = Color(0xFFF5F1E8); // cream page background
  static const card = Color(0xFFFFFDF8);
  static const text = Color(0xFF1B2A24);
  static const muted = Color(0xFF7A7F74);
  static const border = Color(0xFFE6DFD0);
  static const tint = Color(0xFFE4ECE3);
  static const onDark = Color(0xFFDDE7DF); // body text on dark screens
  static const danger = Color(0xFFD9534F);
  static const info = Color(0xFF2F7DD1);
  static const purple = Color(0xFF8A5CC9);
}

class AppText {
  // Android maps 'serif' to Noto Serif, so the display headings need no font package.
  static const display = TextStyle(fontFamily: 'serif', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.15);
  static const h1 = TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text);
  static const h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text);
  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
  static const body = TextStyle(fontSize: 14, color: AppColors.text);
  static const small = TextStyle(fontSize: 12, color: AppColors.muted);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary, secondary: AppColors.accent, surface: AppColors.bg),
        switchTheme: SwitchThemeData(
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
        ),
        sliderTheme: const SliderThemeData(activeTrackColor: AppColors.primary, thumbColor: AppColors.primary, inactiveTrackColor: AppColors.border),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accent),
      );
}
