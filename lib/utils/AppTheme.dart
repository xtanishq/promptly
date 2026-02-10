import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _brandPurple = Color(0xFF8A2BE2);
  static const _brandYellow = Color(0xFFCCFF00);
  static const _background = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);

  // Define family names as constants to avoid typos
  static const String uiFont = 'PlusJakarta';
  // static const String codeFont = 'JetBrainsMono';

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,

      // Senior Tip: Set a global default font family
      fontFamily: uiFont,

      colorScheme: const ColorScheme.dark(
        primary: _brandPurple,
        secondary: _brandYellow,
        surface: _surface,
      ),

      textTheme: const TextTheme(
        // Large Headlines
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        // Standard body text using global font
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        // AI Prompt / Code font specifically
        bodyLarge: TextStyle(
          fontFamily: uiFont,
          fontSize: 15,
          color: _brandYellow,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}