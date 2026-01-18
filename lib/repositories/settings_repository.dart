import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting app settings.
class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';
  static const String _defaultFilterKey = 'default_filter';
  static const String _autoSaveGalleryKey = 'auto_save_gallery';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _cloudProviderKey = 'cloud_provider';

  /// Save the theme mode.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await prefs.setString(_themeModeKey, value);
  }

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

  /// Save the default filter setting.
  Future<void> saveDefaultFilter(String filterName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultFilterKey, filterName);
  }

  /// Load the default filter setting.
  Future<String> loadDefaultFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultFilterKey) ?? 'original';
  }

  /// Save auto-save to gallery setting.
  Future<void> saveAutoSaveToGallery(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveGalleryKey, enabled);
  }

  /// Load auto-save to gallery setting.
  Future<bool> loadAutoSaveToGallery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveGalleryKey) ?? false;
  }

  /// Save haptic feedback setting.
  Future<void> saveHapticFeedback(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
  }

  /// Load haptic feedback setting.
  Future<bool> loadHapticFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  /// Save the cloud provider setting.
  Future<void> saveCloudProvider(String? providerId) async {
    final prefs = await SharedPreferences.getInstance();
    if (providerId == null) {
      await prefs.remove(_cloudProviderKey);
    } else {
      await prefs.setString(_cloudProviderKey, providerId);
    }
  }

  /// Load the cloud provider setting.
  Future<String?> loadCloudProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cloudProviderKey);
  }
}
