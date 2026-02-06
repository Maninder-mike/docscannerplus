import 'package:docscannerplus/features/settings/widgets/settings_group.dart';
import 'package:docscannerplus/features/settings/widgets/settings_tile.dart';
import 'package:docscannerplus/providers/cloud_provider.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class CloudSyncPage extends ConsumerStatefulWidget {
  const CloudSyncPage({super.key});

  @override
  ConsumerState<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends ConsumerState<CloudSyncPage> {
  String? _activeCloudProvider;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initCloudSync();
  }

  Future<void> _initCloudSync() async {
    final cloudRepo = ref.read(cloudRepositoryProvider);
    // Ensure initialized if not already
    if (cloudRepo.activeService == null) {
      await cloudRepo.initialize();
    }
    if (mounted) {
      setState(() {
        _activeCloudProvider = cloudRepo.activeService?.providerId;
      });
    }
  }

  Future<void> _connectCloudProvider(String providerId) async {
    if (_activeCloudProvider == providerId) return;

    final cloudRepo = ref.read(cloudRepositoryProvider);
    final success = await cloudRepo.setProvider(providerId);
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
    await ref.read(cloudRepositoryProvider).disconnect();
    if (mounted) {
      setState(() {
        _activeCloudProvider = null;
      });
    }
  }

  Future<void> _performSync() async {
    if (_activeCloudProvider == null) return;

    setState(() => _isSyncing = true);
    try {
      final syncService = SyncService(
        cloudRepo: ref.read(cloudRepositoryProvider),
        docRepo: ref.read(documentRepositoryProvider),
        analyticsService: ref.read(analyticsServiceProvider),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Connect a cloud provider to sync your documents across devices. Your documents will be backed up automatically.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SettingsGroup(
            title: 'Providers',
            children: [
              _buildProviderTile(
                id: 'google_drive',
                name: 'Google Drive',
                icon: Icons.add_to_drive,
                color: Colors.blue,
              ),
              _buildProviderTile(
                id: 'onedrive',
                name: 'OneDrive',
                icon: Icons.cloud,
                color: Colors.blueAccent,
              ),
            ],
          ),
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
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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

  Widget _buildProviderTile({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final isConnected = _activeCloudProvider == id;
    final theme = Theme.of(context);

    return SettingsTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: name,
      subtitle: isConnected ? 'Connected' : 'Not connected',
      showArrow: false,
      trailing: isConnected
          ? OutlinedButton(
              onPressed: _disconnectCloudProvider,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Disconnect'),
            )
          : FilledButton.tonal(
              onPressed: () => _connectCloudProvider(id),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Connect'),
            ),
    );
  }
}
