import 'package:docscannerplus/folders_page.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:docscannerplus/settings_page.dart';
import 'package:docscannerplus/trash_page.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({super.key});

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _appVersion = '');
    }
  }

  void _openFolders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          onFolderSelected: (folderId, folderName) {
            Navigator.pop(context);
            ref.read(selectedFolderProvider.notifier).select(folderId);
            ref.read(selectedFolderNameProvider.notifier).set(folderName);
          },
        ),
      ),
    );
  }

  void _openTrash(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrashPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _resetSelection() {
    ref.read(selectedFolderProvider.notifier).select(null);
    ref.read(selectedFolderNameProvider.notifier).set(null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedFolder = ref.watch(selectedFolderProvider);

    int? selectedIndex = selectedFolder == null ? 0 : 1;

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        Navigator.pop(context); // Close the drawer
        switch (index) {
          case 0:
            if (selectedFolder != null) _resetSelection();
            ref.read(showFavoritesOnlyProvider.notifier).state = false;
            break;
          case 1:
            if (selectedFolder != null) _resetSelection();
            ref.read(showFavoritesOnlyProvider.notifier).state = true;
            break;
          case 2:
            _openFolders(context);
            break;
          case 3:
            _openTrash(context);
            break;
          case 4:
            _openSettings(context);
            break;
        }
      },
      children: [
        // Premium Header with Gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DocScanner+',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Scan • Organize • Sync',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(12),
        const NavigationDrawerDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('All Documents'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.star_border),
          selectedIcon: Icon(Icons.star),
          label: Text('Favorites'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Folders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.delete_outline),
          selectedIcon: Icon(Icons.delete),
          label: Text('Trash'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const Gap(16),
        Center(
          child: Text(
            _appVersion.isNotEmpty ? 'Version $_appVersion' : 'DocScanner+',
            // Using titleSmall or bodySmall for M3 footer text
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        const Gap(24),
      ],
    );
  }
}
