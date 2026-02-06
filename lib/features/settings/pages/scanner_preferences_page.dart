import 'package:docscannerplus/features/settings/widgets/settings_group.dart';
import 'package:docscannerplus/features/settings/widgets/settings_tile.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:docscannerplus/services/image_filter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannerPreferencesPage extends ConsumerStatefulWidget {
  const ScannerPreferencesPage({super.key});

  @override
  ConsumerState<ScannerPreferencesPage> createState() =>
      _ScannerPreferencesPageState();
}

class _ScannerPreferencesPageState
    extends ConsumerState<ScannerPreferencesPage> {
  String _defaultFilter = 'original';
  bool _autoSaveToGallery = false;
  bool _hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final filter = settingsRepo.loadDefaultFilter();
    final autoSave = settingsRepo.loadAutoSaveToGallery();
    final haptic = settingsRepo.loadHapticFeedback();

    if (mounted) {
      setState(() {
        _defaultFilter = filter;
        _autoSaveToGallery = autoSave;
        _hapticFeedback = haptic;
      });
    }
  }

  Future<void> _updateDefaultFilter(String? newValue) async {
    if (newValue == null) return;
    await ref.read(settingsRepositoryProvider).saveDefaultFilter(newValue);
    if (mounted) setState(() => _defaultFilter = newValue);
  }

  Future<void> _toggleAutoSave(bool enabled) async {
    await ref.read(settingsRepositoryProvider).saveAutoSaveToGallery(enabled);
    if (mounted) setState(() => _autoSaveToGallery = enabled);
  }

  Future<void> _toggleHapticFeedback(bool enabled) async {
    await ref.read(settingsRepositoryProvider).saveHapticFeedback(enabled);
    if (mounted) setState(() => _hapticFeedback = enabled);
  }

  String _getFilterName(String filterKey) {
    try {
      return ImageFilterType.values
          .firstWhere((e) => e.name == filterKey)
          .displayName;
    } catch (_) {
      return 'Original';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Preferences')),
      body: ListView(
        children: [
          SettingsGroup(
            title: 'Scanning',
            children: [
              SettingsTile(
                leading: const Icon(Icons.tune),
                title: 'Default Filter',
                subtitle: _getFilterName(_defaultFilter),
                trailing: DropdownButton<String>(
                  value: _defaultFilter,
                  underline: const SizedBox(),
                  items: ImageFilterType.values.map((type) {
                    return DropdownMenuItem(
                      value: type.name,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: _updateDefaultFilter,
                ),
                showArrow: false,
              ),
              SettingsTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: 'Auto-Save PDF to Files',
                subtitle: 'Automatically save scans as PDF to storage',
                trailing: Switch(
                  value: _autoSaveToGallery,
                  onChanged: _toggleAutoSave,
                ),
                showArrow: false,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Feedback',
            children: [
              SettingsTile(
                leading: const Icon(Icons.vibration),
                title: 'Haptic Feedback',
                trailing: Switch(
                  value: _hapticFeedback,
                  onChanged: _toggleHapticFeedback,
                ),
                showArrow: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
