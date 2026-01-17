import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _securityRepo = SecurityRepository();
  late ThemeMode _selectedTheme;
  String _appVersion = '';
  bool _appLockEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentThemeMode;
    _loadAppInfo();
    _loadSecuritySettings();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            [
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

                  // About Section
                  _buildSectionHeader('About'),
                  const Gap(8),
                  _buildAboutCard(colorScheme),
                ]
                .animate(interval: 50.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.05, end: 0),
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
    final isSelected = _selectedTheme == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedTheme = value);
        widget.onThemeModeChanged(value);
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
              icon: Icons.mail_outlined,
              label: 'Contact Support',
              onTap: () => _launchUrl(
                'mailto:info@maninder.co.in?subject=DocScanner+%20Support',
              ),
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
