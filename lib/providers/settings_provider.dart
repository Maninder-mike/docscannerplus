import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:docscannerplus/providers/core_providers.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
}

@riverpod
class ThemeSetting extends _$ThemeSetting {
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
