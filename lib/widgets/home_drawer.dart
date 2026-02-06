import 'package:docscannerplus/folders_page.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:docscannerplus/settings_page.dart';
import 'package:docscannerplus/trash_page.dart';
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

    return RepaintBoundary(
      child: Drawer(
        child: Column(
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DocScanner+',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                      const Gap(4),
                      Text(
                        'Scan • Organize • Sync',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description,
                    label: 'All Documents',
                    isSelected: selectedFolder == null,
                    onTap: () {
                      Navigator.pop(context);
                      if (selectedFolder != null) _resetSelection();
                    },
                    colorScheme: colorScheme,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.folder_outlined,
                    selectedIcon: Icons.folder,
                    label: 'Folders',
                    isSelected: selectedFolder != null,
                    onTap: () {
                      Navigator.pop(context);
                      _openFolders(context);
                    },
                    colorScheme: colorScheme,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.delete_outline,
                    selectedIcon: Icons.delete,
                    label: 'Trash',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _openTrash(context);
                    },
                    colorScheme: colorScheme,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Settings',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _openSettings(context);
                    },
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _appVersion.isNotEmpty
                      ? 'Version $_appVersion'
                      : 'DocScanner+',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const Gap(16),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
