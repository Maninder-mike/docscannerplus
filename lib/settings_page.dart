import 'package:docscannerplus/features/settings/pages/about_page.dart';
import 'package:docscannerplus/features/settings/pages/cloud_sync_page.dart';
import 'package:docscannerplus/features/settings/pages/scanner_preferences_page.dart';
import 'package:docscannerplus/features/settings/pages/security_page.dart';
import 'package:docscannerplus/features/settings/widgets/settings_group.dart';
import 'package:docscannerplus/features/settings/widgets/settings_tile.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  bool _matchesSearch(String keyword) {
    if (_searchQuery.isEmpty) return true;
    return keyword.toLowerCase().contains(_searchQuery);
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove temporary files and cached images. Your saved documents will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final cacheDir = await getTemporaryDirectory();
        if (cacheDir.existsSync()) {
          await cacheDir.delete(recursive: true);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error clearing cache: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeSettingProvider);

    // If searching, we flatten the list or just show matching tiles
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: _searchQuery.isEmpty
                ? const Text('Settings')
                : TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search settings...',
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  ),
            pinned: true,
            floating: true,
            actions: [
              if (_searchQuery.isEmpty)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchQuery = ' '; // Trigger search mode
                      _searchController.clear();
                    });
                    // Reset after build to show empty results
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _searchQuery = '');
                    });
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                    if (_matchesSearch('scanner preferences filter auto-save'))
                      SettingsGroup(
                        title: isSearching ? null : 'General',
                        children: [
                          SettingsTile(
                            key: const Key('settings_scanner_prefs_tile'),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'Scanner Preferences',
                            subtitle: 'Default filter, auto-save',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ScannerPreferencesPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    if (_matchesSearch(
                      'cloud sync google drive onedrive backup',
                    ))
                      SettingsGroup(
                        title: isSearching ? null : 'Account',
                        children: [
                          SettingsTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.cloud_sync,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'Cloud Sync',
                            subtitle: 'Backup & sync across devices',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CloudSyncPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    if (_matchesSearch('appearance theme dark light system'))
                      SettingsGroup(
                        title: isSearching ? null : 'Appearance',
                        children: [
                          SettingsTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'Theme',
                            subtitle: _getThemeName(themeMode),
                            trailing: DropdownButton<ThemeMode>(
                              value: themeMode,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: ThemeMode.system,
                                  child: Text('System'),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text('Light'),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text('Dark'),
                                ),
                              ],
                              onChanged: (mode) {
                                if (mode != null) {
                                  ref
                                      .read(themeSettingProvider.notifier)
                                      .setThemeMode(mode);
                                }
                              },
                            ),
                            showArrow: false,
                          ),
                        ],
                      ),

                    if (_matchesSearch(
                      'security app lock biometric faceid touchid',
                    ))
                      SettingsGroup(
                        title: isSearching ? null : 'Privacy & Security',
                        children: [
                          SettingsTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'Security',
                            subtitle: 'App lock, Biometrics',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SecurityPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    if (_matchesSearch('storage cache clear data'))
                      SettingsGroup(
                        title: isSearching ? null : 'Data',
                        children: [
                          SettingsTile(
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.cleaning_services,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'Clear Cache',
                            onTap: _clearCache,
                          ),
                        ],
                      ),

                    if (_matchesSearch(
                      'about version help support privacy terms',
                    ))
                      SettingsGroup(
                        title: isSearching ? null : 'Other',
                        children: [
                          SettingsTile(
                            key: const Key('settings_about_tile'),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: 'About',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 50),
                  ]
                  .animate(interval: 50.ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.05, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }
}
