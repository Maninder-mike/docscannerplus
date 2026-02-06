import 'package:docscannerplus/features/settings/widgets/settings_group.dart';
import 'package:docscannerplus/features/settings/widgets/settings_tile.dart';
import 'package:docscannerplus/services/messaging_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
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
      if (mounted) {
        setState(() => _appVersion = 'v26.0.0');
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final mode = uri.scheme == 'mailto'
          ? LaunchMode.platformDefault
          : LaunchMode.inAppBrowserView;

      await launchUrl(uri, mode: mode);
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
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.document_scanner,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'DocScanner+',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Text(
              _appVersion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SettingsGroup(
            title: 'Legal & Support',
            children: [
              SettingsTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: 'Privacy Policy',
                onTap: () => _launchUrl(
                  'https://www.maninder.co.in/docscannerplus/privacypolicy',
                ),
              ),
              SettingsTile(
                leading: const Icon(Icons.description_outlined),
                title: 'Terms of Service',
                onTap: () => _launchUrl(
                  'https://www.maninder.co.in/docscannerplus/terms',
                ),
              ),
              SettingsTile(
                leading: const Icon(Icons.help_outline),
                title: 'Support',
                onTap: () => _launchUrl(
                  'https://www.maninder.co.in/docscannerplus/support',
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Diagnostics',
            children: [
              SettingsTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: 'Copy Debug Info',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final token =
                      MessagingService.instance.fcmToken ?? 'Not available';
                  await Clipboard.setData(
                    ClipboardData(
                      text: 'Version: $_appVersion\nFCM Token: $token',
                    ),
                  );
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Debug info copied to clipboard'),
                    ),
                  );
                },
              ),
              // Only show in debug/profile mode basically, but safe to leave for now as it was there before
              // SettingsTile(
              //   leading: const Icon(Icons.error_outline),
              //   title: 'Force Crash (Test)',
              //   onTap: () => FirebaseCrashlytics.instance.crash(),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
