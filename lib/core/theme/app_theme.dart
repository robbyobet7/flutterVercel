import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent direct instantiation
  const AppTheme._();

  static const List<BoxShadow> kBoxShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 4),
      blurRadius: 5,
    ),
  ];

  static const Color success = Color(0xFF87C991);
  static const Color warning = Color(0xFFFFB259);
  static const Color successContainer = Color(0xFFE5F7DB);
  static const Color warningContainer = Color(0xFFF8EED3);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF598DFF),
      surfaceContainer: const Color(0xFFF4F4F4),
      onSurfaceVariant: const Color(0xFF776F70),
      // secondary: Colors.blueAccent,
      surface: Colors.white,
      error: const Color(0xFFE53935),
      errorContainer: const Color(0xFFE53935).withOpacity(0.1),
      primaryContainer: const Color(0xFF598DFF).withOpacity(0.2),
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F4FD),
    disabledColor: const Color(0xFFD9DBE3),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodyMedium: TextStyle(fontSize: 14.0),
      bodySmall: TextStyle(fontSize: 12.0),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2D33B0),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF598DFF),
      secondary: const Color(0xFF5258FF),
      surface: const Color(0xFF1F1F2C),
      error: const Color(0xFFE53935),
      surfaceContainer: Colors.black.withOpacity(0.2),
    ),
    scaffoldBackgroundColor: const Color(0xFF121220),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1F1F2C),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
      bodySmall: TextStyle(fontSize: 12.0, color: Colors.white70),
    ),
  );
}
