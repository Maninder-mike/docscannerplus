import 'package:docscannerplus/models/folder_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class FoldersPage extends ConsumerStatefulWidget {
  final Function(String? folderId, String? folderName)? onFolderSelected;

  const FoldersPage({super.key, this.onFolderSelected});

  @override
  ConsumerState<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends ConsumerState<FoldersPage> {
  // _folderRepository is TODO: Migration to provider
  // final _folderRepository = FolderRepository();
  List<FolderModel> _folders = [];
  Map<String?, int> _documentCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final folderRepository = ref.read(folderRepositoryProvider);
    final folders = await folderRepository.loadFolders();
    final counts = await ref
        .read(documentRepositoryProvider)
        .getDocumentCountByFolder();
    if (mounted) {
      setState(() {
        _folders = folders;
        _documentCounts = counts;
        _isLoading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final result = await showDialog<FolderModel>(
      context: context,
      builder: (context) => const _FolderDialog(),
    );

    if (result != null) {
      await ref.read(folderRepositoryProvider).addFolder(result);
      await _loadData();
    }
  }

  Future<void> _editFolder(FolderModel folder) async {
    final result = await showDialog<FolderModel>(
      context: context,
      builder: (context) => _FolderDialog(folder: folder),
    );

    if (result != null) {
      await ref.read(folderRepositoryProvider).updateFolder(result);
      await _loadData();
    }
  }

  Future<void> _deleteFolder(FolderModel folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Delete "${folder.name}"? Documents in this folder will be moved to "Uncategorized".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Move documents to uncategorized
      final docRepo = ref.read(documentRepositoryProvider);
      final docs = await docRepo.loadDocumentsInFolder(folder.id);
      for (final doc in docs) {
        await docRepo.moveToFolder(doc, null);
      }
      await ref.read(folderRepositoryProvider).deleteFolder(folder.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            onPressed: _createFolder,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // All Documents
                _buildFolderTile(
                  name: 'All Documents',
                  icon: Icons.description,
                  color: colorScheme.primary,
                  count: _documentCounts.values.fold(0, (a, b) => a + b),
                  onTap: () => widget.onFolderSelected?.call(null, null),
                ),
                const Gap(8),

                // Uncategorized
                _buildFolderTile(
                  name: 'Uncategorized',
                  icon: Icons.folder_off_outlined,
                  color: colorScheme.outline,
                  count: _documentCounts[null] ?? 0,
                  onTap: () => widget.onFolderSelected?.call(
                    'uncategorized',
                    'Uncategorized',
                  ),
                ),

                if (_folders.isNotEmpty) ...[
                  const Gap(16),
                  Text(
                    'My Folders',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                ],

                ..._folders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final folder = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildFolderTile(
                      name: folder.name,
                      icon: folder.icon,
                      color: folder.color,
                      count: _documentCounts[folder.id] ?? 0,
                      onTap: () =>
                          widget.onFolderSelected?.call(folder.id, folder.name),
                      onLongPress: () => _showFolderOptions(folder),
                    ).animate().fadeIn(delay: (index * 50).ms),
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        label: const Text('New Folder'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFolderTile({
    required String name,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Gap(8),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderOptions(FolderModel folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Folder'),
              onTap: () {
                Navigator.pop(context);
                _editFolder(folder);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Folder',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(folder);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderDialog extends StatefulWidget {
  final FolderModel? folder;

  const _FolderDialog({this.folder});

  @override
  State<_FolderDialog> createState() => _FolderDialogState();
}

class _FolderDialogState extends State<_FolderDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder?.name ?? '');
    _selectedColor = widget.folder?.color ?? FolderModel.availableColors.first;
    _selectedIcon = widget.folder?.icon ?? FolderModel.availableIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.folder == null ? 'New Folder' : 'Edit Folder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Folder Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const Gap(16),

            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FolderModel.availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const Gap(16),

            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FolderModel.availableIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: _selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? _selectedColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final folder = widget.folder != null
                ? widget.folder!.copyWith(
                    name: name,
                    color: _selectedColor,
                    icon: _selectedIcon,
                  )
                : FolderModel.create(
                    name: name,
                    color: _selectedColor,
                    icon: _selectedIcon,
                  );

            Navigator.pop(context, folder);
          },
          child: Text(widget.folder == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
