import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting app settings.
class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';

  /// Load the saved theme mode.
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Save the theme mode.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.dark:
        value = 'dark';
      case ThemeMode.system:
        value = 'system';
    }
    await prefs.setString(_themeModeKey, value);
  }
}
