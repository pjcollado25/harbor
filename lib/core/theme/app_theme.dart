import 'package:flutter/material.dart';

class AppTheme {
  static const blue = Color(0xFF73B3FF);
  static const darkCanvas = Colors.black;
  static const lightCanvas = Colors.white;

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: blue,
      onPrimary: Color(0xFF07111E),
      secondary: Color(0xFF9BCBFF),
      surface: Color(0xFF111722),
      onSurface: Color(0xFFF1F5FA),
      error: Color(0xFFFF8C84),
      outline: Color(0xFF303C4B),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkCanvas,
      canvasColor: darkCanvas,
      dividerColor: const Color(0xFF303C4B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF1F5FA),
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111722),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF303C4B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF303C4B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color(0xFFF1F5FA),
        displayColor: const Color(0xFFF1F5FA),
      ),
    );
  }

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: Color(0xFF255D96),
      onPrimary: Colors.white,
      secondary: Color(0xFF337DC0),
      surface: Colors.white,
      onSurface: Color(0xFF1C2836),
      error: Color(0xFF9A342E),
      outline: Color(0xFFD2DEEA),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightCanvas,
      canvasColor: lightCanvas,
      dividerColor: const Color(0xFFD2DEEA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1C2836),
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD2DEEA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD2DEEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF337DC0), width: 1.5),
        ),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: const Color(0xFF1C2836),
        displayColor: const Color(0xFF1C2836),
      ),
    );
  }
}
