import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// AppTheme defines the premium Material 3 themes for TaskPlano.
///
/// Design language: modern productivity — deep indigo seed with tonal
/// palette, generous radius, and subtle elevation.
class AppTheme {
  AppTheme._();

  // ── Brand palette ─────────────────────────────────────────────────────────
  /// Primary seed — deep indigo violet.
  static const Color primarySeed = Color(0xFF4F46E5);

  /// Gradient used on the home screen background.
  static const List<Color> lightGradient = [
    Color(0xFFF0EFFF),
    Color(0xFFE8F4FD),
    Color(0xFFF5F0FF),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0F0E1A),
    Color(0xFF111827),
    Color(0xFF0D1117),
  ];

  /// Glass surface colour for light mode.
  static const Color glassLight = Color(0xCCFFFFFF);

  /// Glass surface colour for dark mode.
  static const Color glassDark = Color(0x1AFFFFFF);

  // ── Shared component styles ───────────────────────────────────────────────

  static AppBarTheme _appBarTheme(Brightness brightness) => AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            brightness == Brightness.light ? const Color(0xFF1A1A2E) : Colors.white,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      );

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
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
          borderSide: const BorderSide(color: primarySeed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      );

  static FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  static ChipThemeData get _chipTheme => ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      );

  static TabBarThemeData get _tabBarTheme => const TabBarThemeData(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.light,
          surface: const Color(0xFFF8F7FF),
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: _appBarTheme(Brightness.light),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputTheme,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        chipTheme: _chipTheme,
        tabBarTheme: _tabBarTheme,
        textTheme: _textTheme(Brightness.light),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111827),
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: _appBarTheme(Brightness.dark),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputTheme,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        chipTheme: _chipTheme,
        tabBarTheme: _tabBarTheme,
        textTheme: _textTheme(Brightness.dark),
      );

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? const Color(0xFF1A1A2E)
        : Colors.white;
    return TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.w800, letterSpacing: -1.5, color: base),
      displayMedium: TextStyle(
          fontWeight: FontWeight.w700, letterSpacing: -1.0, color: base),
      headlineLarge: TextStyle(
          fontWeight: FontWeight.w700, letterSpacing: -0.5, color: base),
      headlineMedium: TextStyle(
          fontWeight: FontWeight.w700, letterSpacing: -0.5, color: base),
      headlineSmall: TextStyle(
          fontWeight: FontWeight.w600, letterSpacing: -0.3, color: base),
      titleLarge: TextStyle(
          fontWeight: FontWeight.w600, letterSpacing: -0.2, color: base),
      titleMedium: TextStyle(fontWeight: FontWeight.w500, color: base),
      bodyLarge: TextStyle(
          fontWeight: FontWeight.w400, height: 1.5, color: base),
      bodyMedium: TextStyle(
          fontWeight: FontWeight.w400, height: 1.5, color: base),
    );
  }
}
