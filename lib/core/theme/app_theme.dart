import 'package:flutter/material.dart';

class AppTheme {
  static const blue = Color(0xFF73B3FF);
  static const accent = Color(0xFFB8B8BD);
  static const darkCanvas = Color(0xFF0A0A0A);
  static const lightCanvas = Colors.white;

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Color(0xFF0A0A0A),
      secondary: Color(0xFFC1C1C6),
      surface: Color(0xFF121214),
      onSurface: Color(0xFFF2F2F7),
      error: Color(0xFFFF6961),
      outline: Color(0xFF2C2C2E),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkCanvas,
      canvasColor: darkCanvas,
      dividerColor: const Color(0xFF2C2C2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121214),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5A5A5F), width: 1.5),
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color(0xFFF2F2F7),
        displayColor: const Color(0xFFF2F2F7),
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
      dividerColor: const Color(0xFFB7C6D6),
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

extension HarborThemeContext on BuildContext {
  Color harborOnSurface([double alpha = 0.62]) =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: alpha);

  TextStyle harborMutedText({
    double alpha = 0.62,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final theme = Theme.of(this);
    final base = theme.textTheme.bodySmall ?? theme.textTheme.bodyMedium!;
    return base.copyWith(
      fontSize: fontSize ?? base.fontSize,
      fontWeight: fontWeight ?? base.fontWeight,
      color: theme.colorScheme.onSurface.withValues(alpha: alpha),
    );
  }
}
