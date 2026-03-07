import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:docscannerplus/providers/core_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});

final themeSettingProvider = NotifierProvider<ThemeSetting, ThemeMode>(() {
  return ThemeSetting();
});

class ThemeSetting extends Notifier<ThemeMode> {
  late final SettingsRepository _repository;

  @override
  ThemeMode build() {
    _repository = ref.watch(settingsRepositoryProvider);
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final mode = _repository.loadThemeMode();
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repository.saveThemeMode(mode);
  }
}
