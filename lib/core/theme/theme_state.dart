import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// ThemeState holds the currently active [ThemeMode].
///
/// Equatable ensures BlocBuilder only rebuilds when the mode actually changes.
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);

  /// Convenience getters used by the toggle icon in the AppBar.
  bool get isDark => themeMode == ThemeMode.dark;
  bool get isLight => themeMode == ThemeMode.light;

  @override
  List<Object?> get props => [themeMode];
}
