import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6C63FF);
  static const secondaryColor = Color(0xFF2A2D3E);
  static const accentColor = Color(0xFF00D1FF);
  static const backgroundColor = Color(0xFF1A1C29);
  static const cardColor = Color(0xFF242736);
  static const successColor = Color(0xFF4CAF50);
  static const warningColor = Color(0xFFFFC107);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    cardColor: cardColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
