import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting app settings.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String _themeModeKey = 'theme_mode';
  static const String _defaultFilterKey = 'default_filter';
  static const String _autoSaveGalleryKey = 'auto_save_gallery';
  static const String _hapticFeedbackKey = 'haptic_feedback';
  static const String _cloudProviderKey = 'cloud_provider';

  /// Save the theme mode.
  Future<void> saveThemeMode(ThemeMode mode) async {
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
    await _prefs.setString(_themeModeKey, value);
  }

  /// Load the saved theme mode.
  ThemeMode loadThemeMode() {
    final value = _prefs.getString(_themeModeKey);
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
    await _prefs.setString(_defaultFilterKey, filterName);
  }

  /// Load the default filter setting.
  String loadDefaultFilter() {
    return _prefs.getString(_defaultFilterKey) ?? 'original';
  }

  /// Save auto-save to gallery setting.
  Future<void> saveAutoSaveToGallery(bool enabled) async {
    await _prefs.setBool(_autoSaveGalleryKey, enabled);
  }

  /// Load auto-save to gallery setting.
  bool loadAutoSaveToGallery() {
    return _prefs.getBool(_autoSaveGalleryKey) ?? false;
  }

  /// Save haptic feedback setting.
  Future<void> saveHapticFeedback(bool enabled) async {
    await _prefs.setBool(_hapticFeedbackKey, enabled);
  }

  /// Load haptic feedback setting.
  bool loadHapticFeedback() {
    return _prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  /// Save the cloud provider setting.
  Future<void> saveCloudProvider(String? providerId) async {
    if (providerId == null) {
      await _prefs.remove(_cloudProviderKey);
    } else {
      await _prefs.setString(_cloudProviderKey, providerId);
    }
  }

  /// Load the cloud provider setting.
  String? loadCloudProvider() {
    return _prefs.getString(_cloudProviderKey);
  }

  /// Check if cloud sync is enabled (provider is selected).
  Future<bool> getCloudEnabled() async {
    return loadCloudProvider() != null;
  }
}
