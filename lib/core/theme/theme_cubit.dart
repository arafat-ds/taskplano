import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/core/theme/theme_state.dart';

/// ThemeCubit manages the app-wide theme mode (light / dark / system).
///
/// It is registered as a lazySingleton in GetIt and provided at the root of
/// the widget tree so every screen can read and toggle the theme.
///
/// ── Persistence note ─────────────────────────────────────────────────────────
/// The selected mode is currently in-memory only — it resets on app restart.
/// To persist it, inject a Hive box or SharedPreferences and call
/// [toggleTheme] after writing the value. No other code needs to change.
/// ─────────────────────────────────────────────────────────────────────────────
class ThemeCubit extends Cubit<ThemeState> {
  /// Starts in system mode so the app respects the device setting by default.
  ThemeCubit() : super(const ThemeState(ThemeMode.system));

  /// Cycles: system → light → dark → light → dark → …
  ///
  /// First toggle from system always goes to light so the user sees an
  /// immediate, predictable change regardless of their device setting.
  void toggleTheme() {
    final next = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
    };
    emit(ThemeState(next));
  }

  /// Explicitly sets a specific [ThemeMode].
  void setTheme(ThemeMode mode) => emit(ThemeState(mode));
}
