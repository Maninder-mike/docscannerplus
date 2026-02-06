import 'package:docscannerplus/features/settings/widgets/settings_group.dart';
import 'package:docscannerplus/features/settings/widgets/settings_tile.dart';
import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _securityRepo = SecurityRepository();
  bool _appLockEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        children: [
          SettingsGroup(
            title: 'App Lock',
            children: [
              SettingsTile(
                leading: const Icon(Icons.security),
                title: 'Biometric Lock',
                subtitle: _biometricAvailable
                    ? 'Require FaceID/TouchID to open app'
                    : 'Biometric authentication not available',
                trailing: Switch(
                  value: _appLockEnabled,
                  onChanged: _biometricAvailable ? _toggleAppLock : null,
                ),
                showArrow: false,
              ),
            ],
          ),
          if (!_biometricAvailable)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Biometric authentication is not supported or not set up on this device.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
