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
        SliverAppBar.medium(
          title: Text(
            isSelectionMode ? '$selectedCount selected' : 'DocScanner+',
          ),
          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClearSelection,
                )
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: onOpenDrawer,
                ),
          actions: isSelectionMode
              ? [
                  if (selectedCount == 1) ...[
                    IconButton(
                      onPressed: onRename,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Rename',
                    ),
                    IconButton(
                      onPressed: onEditTags,
                      icon: const Icon(Icons.label),
                      tooltip: 'Edit Tags',
                    ),
                    IconButton(
                      onPressed: onExtractText,
                      icon: const Icon(Icons.text_fields),
                      tooltip: 'OCR',
                    ),
                    IconButton(
                      onPressed: onReorderPages,
                      icon: const Icon(Icons.sort),
                      tooltip: 'Reorder Pages',
                    ),
                    IconButton(
                      onPressed: onSignDocument,
                      icon: const Icon(Icons.draw),
                      tooltip: 'Sign',
                    ),
                    IconButton(
                      onPressed: onAddWatermark,
                      icon: const Icon(Icons.branding_watermark),
                      tooltip: 'Watermark',
                    ),
                  ],
                  if (selectedCount > 1)
                    IconButton(
                      onPressed: onMerge,
                      icon: const Icon(Icons.merge_type),
                      tooltip: 'Merge',
                    ),
                  IconButton(onPressed: onShare, icon: const Icon(Icons.share)),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                  ),
                ]
              : [
                  IconButton(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                  ),
                ],
        ),
        if (isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          const AnnouncementBanner(),
          if (selectedFolderId != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    InputChip(
                      label: Text(selectedFolderName ?? 'Folder'),
                      avatar: const Icon(Icons.folder_outlined, size: 18),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        ref.read(selectedFolderProvider.notifier).select(null);
                        ref.read(selectedFolderNameProvider.notifier).set(null);
                      },
                      selected: true,
                      showCheckmark: false,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}
