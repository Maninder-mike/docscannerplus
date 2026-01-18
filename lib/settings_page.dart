import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/services/image_filter_service.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:docscannerplus/services/messaging_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _securityRepo = SecurityRepository();
  final _settingsRepo = SettingsRepository();
  late final CloudRepository _cloudRepo;
  String _appVersion = '';

  // Settings State
  String _defaultFilter = 'original';
  bool _autoSaveToGallery = false;
  bool _hapticFeedback = true;

  bool _appLockEnabled = false;
  bool _biometricAvailable = false;
  String? _activeCloudProvider;

  @override
  void initState() {
    super.initState();
    // Theme is loaded/managed by Riverpod provider
    _cloudRepo = CloudRepository(settingsRepo: _settingsRepo);
    _loadAppInfo();
    _loadSecuritySettings();
    _loadPreferences();
    _initCloudSync();
  }

  Future<void> _initCloudSync() async {
    await _cloudRepo.initialize();
    if (mounted) {
      setState(() {
        _activeCloudProvider = _cloudRepo.activeService?.providerId;
      });
    }
  }

  Future<void> _loadPreferences() async {
    final filter = await _settingsRepo.loadDefaultFilter();
    final autoSave = await _settingsRepo.loadAutoSaveToGallery();
    final haptic = await _settingsRepo.loadHapticFeedback();

    if (mounted) {
      setState(() {
        _defaultFilter = filter;
        _autoSaveToGallery = autoSave;
        _hapticFeedback = haptic;
      });
    }
  }

  Future<void> _loadSecuritySettings() async {
    final lockEnabled = await _securityRepo.isAppLockEnabled();
    final biometricAvailable = await _securityRepo.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _appLockEnabled = lockEnabled;
        _biometricAvailable = biometricAvailable;
      });
    }
  }

  Future<void> _toggleAppLock(bool enabled) async {
    if (enabled) {
      // Verify biometric before enabling
      final success = await _securityRepo.authenticate(
        reason: 'Verify to enable app lock',
      );
      if (!success) return;
    }

    await _securityRepo.setAppLockEnabled(enabled);
    if (mounted) {
      setState(() => _appLockEnabled = enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enabled ? 'App lock enabled' : 'App lock disabled'),
        ),
      );
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'v${info.version} (${info.buildNumber})';
        });
      }
    } catch (_) {
      // Fallback if package_info_plus isn't available
      if (mounted) {
        setState(() => _appVersion = 'v26.0.0');
      }
    }
  }

  Future<void> _updateDefaultFilter(String? newValue) async {
    if (newValue == null) return;
    await _settingsRepo.saveDefaultFilter(newValue);
    if (mounted) setState(() => _defaultFilter = newValue);
  }

  Future<void> _toggleAutoSave(bool enabled) async {
    await _settingsRepo.saveAutoSaveToGallery(enabled);
    if (mounted) setState(() => _autoSaveToGallery = enabled);
  }

  Future<void> _toggleHapticFeedback(bool enabled) async {
    await _settingsRepo.saveHapticFeedback(enabled);
    if (mounted) setState(() => _hapticFeedback = enabled);
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      // Use in-app browser for web URLs, platform default for mailto
      final mode = uri.scheme == 'mailto'
          ? LaunchMode.platformDefault
          : LaunchMode.inAppBrowserView;

      final launched = await launchUrl(uri, mode: mode);
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
      }
    }
  }

  Future<void> _connectCloudProvider(String providerId) async {
    // If selecting the one already active, do nothing or show info
    if (_activeCloudProvider == providerId) return;

    final success = await _cloudRepo.setProvider(providerId);
    if (mounted) {
      setState(() {
        _activeCloudProvider = success ? providerId : null;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to cloud provider')),
        );
      }
    }
  }

  Future<void> _disconnectCloudProvider() async {
    await _cloudRepo.disconnect();
    if (mounted) {
      setState(() {
        _activeCloudProvider = null;
      });
    }
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

  bool _isSyncing = false;

  Future<void> _performSync() async {
    if (_activeCloudProvider == null) return;

    setState(() => _isSyncing = true);
    try {
      final syncService = SyncService(
        cloudRepo: _cloudRepo,
        docRepo: DocumentRepository(),
      );
      final result = await syncService.sync();

      if (mounted) {
        final uploaded = result[0];
        final downloaded = result[1];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync Complete: +$uploaded uploaded, +$downloaded downloaded',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Widget _buildCloudSyncCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Connect one cloud provider to sync your documents across devices.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildProviderOption(
            id: 'google_drive',
            name: 'Google Drive',
            icon: Icons.add_to_drive, // Or use a custom asset
            color: Colors.blue, // Simplified color
            colorScheme: colorScheme,
          ),
          const Divider(height: 1, indent: 56),
          _buildProviderOption(
            id: 'onedrive',
            name: 'OneDrive',
            icon: Icons.cloud, // Generic cloud for OneDrive
            color: Colors.blueAccent,
            colorScheme: colorScheme,
          ),
          const Divider(height: 1),
          if (_activeCloudProvider != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isSyncing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const Gap(12),
                        Text(
                          'Syncing...',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    )
                  : FilledButton.icon(
                      onPressed: _performSync,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync Now'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderOption({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final isConnected = _activeCloudProvider == id;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(name),
      subtitle: Text(
        isConnected ? 'Connected' : 'Not connected',
        style: TextStyle(
          color: isConnected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isConnected
          ? OutlinedButton(
              onPressed: _disconnectCloudProvider,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
              child: const Text('Disconnect'),
            )
          : FilledButton.tonal(
              onPressed: () => _connectCloudProvider(id),
              child: const Text('Connect'),
            ),
    );
  }

  Widget _buildScannerPreferencesCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.tune, color: colorScheme.primary),
            title: const Text('Default Filter'),
            subtitle: Text(
              _getFilterName(_defaultFilter),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
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
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: Icon(
              Icons.photo_library_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Auto-Save PDF to Files'),
            subtitle: Text(
              'Automatically save scans as PDF to storage',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            value: _autoSaveToGallery,
            onChanged: _toggleAutoSave,
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: Icon(Icons.vibration, color: colorScheme.primary),
            title: const Text('Haptic Feedback'),
            value: _hapticFeedback,
            onChanged: _toggleHapticFeedback,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          Icons.cleaning_services_outlined,
          color: colorScheme.primary,
        ),
        title: const Text('Clear Cache'),
        subtitle: const Text('Free up space by removing temporary files'),
        onTap: _clearCache,
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children:
                [
                      // Scanner Preferences
                      _buildSectionHeader('Scanner Preferences'),
                      const Gap(8),
                      _buildScannerPreferencesCard(colorScheme),
                      const Gap(24),

                      // Cloud Sync Section
                      _buildSectionHeader('Cloud Sync'),
                      const Gap(8),
                      _buildCloudSyncCard(colorScheme),
                      const Gap(24),

                      // Appearance Section
                      _buildSectionHeader('Appearance'),
                      const Gap(8),
                      _buildThemeCard(colorScheme),
                      const Gap(24),

                      // Security Section
                      _buildSectionHeader('Security'),
                      const Gap(8),
                      _buildSecurityCard(colorScheme),
                      const Gap(24),

                      // Storage Section
                      _buildSectionHeader('Storage & Data'),
                      const Gap(8),
                      _buildStorageCard(colorScheme),
                      const Gap(24),

                      // About Section
                      _buildSectionHeader('About'),
                      const Gap(8),
                      _buildAboutCard(colorScheme),
                    ]
                    .animate(interval: 50.ms)
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05, end: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildThemeCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: colorScheme.primary),
                const Gap(12),
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Gap(16),
            _buildThemeOption(
              icon: Icons.brightness_auto,
              label: 'System',
              value: ThemeMode.system,
              colorScheme: colorScheme,
            ),
            _buildThemeOption(
              icon: Icons.light_mode,
              label: 'Light',
              value: ThemeMode.light,
              colorScheme: colorScheme,
            ),
            _buildThemeOption(
              icon: Icons.dark_mode,
              label: 'Dark',
              value: ThemeMode.dark,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required ThemeMode value,
    required ColorScheme colorScheme,
  }) {
    // UPDATED: Using Riverpod to watch and set theme
    final currentTheme = ref.watch(themeModeProvider);
    final isSelected = currentTheme == value;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            const Gap(12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security_outlined, color: colorScheme.primary),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Lock',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(2),
                      Text(
                        'Require biometrics to open app',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _appLockEnabled,
                  onChanged: _biometricAvailable ? _toggleAppLock : null,
                ),
              ],
            ),
            if (!_biometricAvailable) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Biometric authentication not available on this device',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.document_scanner,
                    color: colorScheme.primary,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DocScanner+',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _appVersion,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            const Divider(height: 1),
            const Gap(8),

            // Links
            _buildAboutLink(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () => _launchUrl(
                'https://www.maninder.co.in/docscannerplus/privacypolicy',
              ),
            ),
            _buildAboutLink(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              onTap: () =>
                  _launchUrl('https://www.maninder.co.in/docscannerplus/terms'),
            ),
            _buildAboutLink(
              icon: Icons.help_outline,
              label: 'Support',
              onTap: () => _launchUrl(
                'https://www.maninder.co.in/docscannerplus/support',
              ),
            ),
            _buildAboutLink(
              icon: Icons.bug_report_outlined,
              label: 'Copy Debug Info',
              onTap: () async {
                final token =
                    MessagingService.instance.fcmToken ?? 'Not available';
                await Clipboard.setData(
                  ClipboardData(
                    text: 'Version: $_appVersion\nFCM Token: $token',
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debug info copied to clipboard'),
                    ),
                  );
                }
              },
            ),
            _buildAboutLink(
              icon: Icons.error_outline,
              label: 'Force Crash (Test)',
              onTap: () => FirebaseCrashlytics.instance.crash(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
            const Gap(12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
