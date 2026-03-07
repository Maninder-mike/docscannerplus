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
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      controller.openView();
                    },
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                      final String keyword = controller.text.toLowerCase();

                      // Simple predefined list of settings
                      final List<Map<String, dynamic>> allSettings = [
                        {
                          'title': 'Scanner Preferences',
                          'subtitle': 'Default filter, auto-save',
                          'icon': Icons.tune,
                          'route': const ScannerPreferencesPage(),
                        },
                        {
                          'title': 'Cloud Sync',
                          'subtitle': 'Backup & sync across devices',
                          'icon': Icons.cloud_sync,
                          'route': const CloudSyncPage(),
                        },
                        {
                          'title': 'Theme',
                          'subtitle': 'Appearance',
                          'icon': Icons.palette,
                          'route': null,
                        },
                        {
                          'title': 'Security',
                          'subtitle': 'App lock, Biometrics',
                          'icon': Icons.security,
                          'route': const SecurityPage(),
                        },
                        {
                          'title': 'Clear Cache',
                          'subtitle': 'Storage, Data',
                          'icon': Icons.cleaning_services,
                          'route': null,
                          'action': 'clear_cache',
                        },
                        {
                          'title': 'About',
                          'subtitle': 'Version, Help, Privacy',
                          'icon': Icons.info,
                          'route': const AboutPage(),
                        },
                      ];

                      final matches = allSettings.where(
                        (s) =>
                            (s['title'] as String).toLowerCase().contains(
                              keyword,
                            ) ||
                            (s['subtitle'] as String).toLowerCase().contains(
                              keyword,
                            ),
                      );

                      return matches.map(
                        (s) => ListTile(
                          leading: Icon(s['icon'] as IconData),
                          title: Text(s['title'] as String),
                          subtitle: Text(s['subtitle'] as String),
                          onTap: () {
                            controller.closeView(null);
                            final route = s['route'];
                            final action = s['action'];

                            if (route != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => route as Widget,
                                ),
                              );
                            } else if (action == 'clear_cache') {
                              _clearCache();
                            }
                          },
                        ),
                      );
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                size: 24,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.cloud_sync,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                size: 24,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.palette,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Theme',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: SegmentedButton<ThemeMode>(
                                    segments: const [
                                      ButtonSegment(
                                        value: ThemeMode.system,
                                        label: Text('System'),
                                        icon: Icon(Icons.brightness_auto),
                                      ),
                                      ButtonSegment(
                                        value: ThemeMode.light,
                                        label: Text('Light'),
                                        icon: Icon(Icons.light_mode),
                                      ),
                                      ButtonSegment(
                                        value: ThemeMode.dark,
                                        label: Text('Dark'),
                                        icon: Icon(Icons.dark_mode),
                                      ),
                                    ],
                                    selected: {themeMode},
                                    onSelectionChanged:
                                        (Set<ThemeMode> newSelection) {
                                          ref
                                              .read(
                                                themeSettingProvider.notifier,
                                              )
                                              .setThemeMode(newSelection.first);
                                        },
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.security,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                size: 24,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.cleaning_services,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 24,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 24,
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
}
