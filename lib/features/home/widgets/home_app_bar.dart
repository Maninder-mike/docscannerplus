import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/widgets/announcement_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAppBar extends ConsumerWidget {
  final VoidCallback onClearSelection;
  final VoidCallback onOpenDrawer;
  final VoidCallback onRename;
  final VoidCallback onEditTags;
  final VoidCallback onExtractText;
  final VoidCallback onReorderPages;
  final VoidCallback onSignDocument;
  final VoidCallback onAddWatermark;
  final VoidCallback onMerge;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final bool isLoading;

  const HomeAppBar({
    super.key,
    required this.onClearSelection,
    required this.onOpenDrawer,
    required this.onRename,
    required this.onEditTags,
    required this.onExtractText,
    required this.onReorderPages,
    required this.onSignDocument,
    required this.onAddWatermark,
    required this.onMerge,
    required this.onShare,
    required this.onDelete,
    required this.onSearch,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final selectedCount = ref.watch(selectionProvider).length;
    final selectedFolderId = ref.watch(selectedFolderProvider);
    final selectedFolderName = ref.watch(selectedFolderNameProvider);

    return SliverMainAxisGroup(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            isSelectionMode
                ? '$selectedCount selected'
                : selectedFolderId != null
                ? (selectedFolderName ?? 'Folder')
                : 'DocScanner+',
          ),
          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClearSelection,
                )
              : selectedFolderId != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(selectedFolderProvider.notifier).select(null);
                    ref.read(selectedFolderNameProvider.notifier).set(null);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: onOpenDrawer,
                ),
          actions: isSelectionMode
              ? [
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    tooltip: 'Share',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More options',
                    onSelected: (value) {
                      switch (value) {
                        case 'rename':
                          onRename();
                          break;
                        case 'tags':
                          onEditTags();
                          break;
                        case 'ocr':
                          onExtractText();
                          break;
                        case 'reorder':
                          onReorderPages();
                          break;
                        case 'sign':
                          onSignDocument();
                          break;
                        case 'watermark':
                          onAddWatermark();
                          break;
                        case 'merge':
                          onMerge();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (selectedCount == 1) ...[
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Rename'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'tags',
                          child: Row(
                            children: [
                              Icon(
                                Icons.label,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Edit Tags'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'ocr',
                          child: Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Extract Text (OCR)'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reorder',
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Reorder Pages'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'sign',
                          child: Row(
                            children: [
                              Icon(
                                Icons.draw,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Sign Document'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'watermark',
                          child: Row(
                            children: [
                              Icon(
                                Icons.branding_watermark,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Add Watermark'),
                            ],
                          ),
                        ),
                      ],
                      if (selectedCount > 1)
                        PopupMenuItem(
                          value: 'merge',
                          child: Row(
                            children: [
                              Icon(
                                Icons.merge_type,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Merge Documents'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ]
              : [
                  IconButton(
                    icon: Icon(
                      ref.watch(isGridViewProvider)
                          ? Icons.view_list
                          : Icons.grid_view,
                    ),
                    onPressed: () {
                      ref.read(isGridViewProvider.notifier).state = !ref.read(
                        isGridViewProvider,
                      );
                    },
                    tooltip: 'Toggle View',
                  ),
                  IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                  ),
                ],
          bottom: isSelectionMode
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: const [
                          _SortChip(),
                          SizedBox(width: 8),
                          _FilterChip(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        if (isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          const AnnouncementBanner(),
        ],
      ],
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortValue = ref.watch(documentSortProvider);

    String labelText;
    switch (sortValue) {
      case DocumentSortOption.dateDesc:
        labelText = 'Date (Newest)';
        break;
      case DocumentSortOption.dateAsc:
        labelText = 'Date (Oldest)';
        break;
      case DocumentSortOption.nameAsc:
        labelText = 'Name (A-Z)';
        break;
      case DocumentSortOption.nameDesc:
        labelText = 'Name (Z-A)';
        break;
    }

    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text('Sort: $labelText'),
      onPressed: () {
        // Cycle through sort options
        DocumentSortOption nextSort;
        switch (sortValue) {
          case DocumentSortOption.dateDesc:
            nextSort = DocumentSortOption.dateAsc;
            break;
          case DocumentSortOption.dateAsc:
            nextSort = DocumentSortOption.nameAsc;
            break;
          case DocumentSortOption.nameAsc:
            nextSort = DocumentSortOption.nameDesc;
            break;
          case DocumentSortOption.nameDesc:
            nextSort = DocumentSortOption.dateDesc;
            break;
        }
        ref.read(documentSortProvider.notifier).state = nextSort;
      },
    );
  }
}

class _FilterChip extends ConsumerWidget {
  const _FilterChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDocsAsync = ref.watch(activeDocumentsProvider);
    final filterValue = ref.watch(documentTagFilterProvider);

    return activeDocsAsync.when(
      data: (docs) {
        final tags = docs.expand((doc) => doc.tags).toSet().toList()..sort();

        if (tags.isEmpty && filterValue == null) {
          return const SizedBox.shrink();
        }

        return ActionChip(
          avatar: Icon(
            filterValue == null ? Icons.filter_list : Icons.label,
            size: 16,
          ),
          label: Text(filterValue ?? 'Filter'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        title: Text(
                          'Filter by Tag',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.clear),
                        title: const Text('Clear Filter'),
                        onTap: () {
                          ref.read(documentTagFilterProvider.notifier).state =
                              null;
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      ...tags.map(
                        (tag) => ListTile(
                          leading: const Icon(Icons.label_outline),
                          title: Text(tag),
                          trailing: filterValue == tag
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () {
                            ref.read(documentTagFilterProvider.notifier).state =
                                tag;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
