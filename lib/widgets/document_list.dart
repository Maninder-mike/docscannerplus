import 'dart:io';

import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/services/thumbnail_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:open_filex/open_filex.dart';

class DocumentList extends ConsumerWidget {
  const DocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch documents
    final documentsAsync = ref.watch(activeDocumentsProvider);

    return documentsAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          SliverFillRemaining(child: Center(child: Text('Error: $err'))),
      data: (allDocuments) {
        // 2. Filter by Folder
        final selectedFolderId = ref.watch(selectedFolderProvider);
        final documents = selectedFolderId == null
            ? allDocuments
            : allDocuments
                  .where((d) => d.folderId == selectedFolderId)
                  .toList();

        if (documents.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const Gap(16),
                  Text(
                    'No documents yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const Gap(8),
                  Text(
                    'Tap the + button to scan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.70,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final doc = documents[index];
              return DocumentCard(doc: doc, index: index);
            }, childCount: documents.length),
          ),
        );
      },
    );
  }
}

class DocumentCard extends ConsumerWidget {
  final DocumentModel doc;
  final int index;

  const DocumentCard({super.key, required this.doc, required this.index});

  String _getFilterShortName(String filterType) {
    switch (filterType) {
      case 'autoEnhance':
        return 'Auto';
      case 'blackAndWhite':
        return 'B&W';
      case 'grayscale':
        return 'Gray';
      case 'magicColor':
        return 'Magic';
      default:
        return filterType;
    }
  }

  Future<void> _openDocument(BuildContext context, DocumentModel doc) async {
    if (doc.filePath != null) {
      final result = await OpenFilex.open(doc.filePath!);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('File path not found')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectionProvider);
    final isSelected = selectedIds.contains(doc.id);
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return GestureDetector(
          onLongPress: () {
            ref
                .read(selectionProvider.notifier)
                .select(doc.id); // Triggers selection mode
          },
          onTap: () {
            if (isSelectionMode) {
              ref.read(selectionProvider.notifier).toggle(doc.id);
            } else {
              _openDocument(context, doc);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _ThumbnailWidget(doc: doc),
                      if (isSelected || isSelectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            doc.formattedDate,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                          ),
                          Row(
                            children: [
                              if (doc.filterType != null &&
                                  doc.filterType != 'original')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_fix_high,
                                        size: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer,
                                      ),
                                      const Gap(2),
                                      Text(
                                        _getFilterShortName(doc.filterType!),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (doc.pageCount > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${doc.pageCount}p',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms)
        .slideY(begin: 0.1, duration: 400.ms);
  }
}

class _ThumbnailWidget extends StatefulWidget {
  final DocumentModel doc;
  const _ThumbnailWidget({required this.doc});

  @override
  State<_ThumbnailWidget> createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<_ThumbnailWidget> {
  final _thumbnailService = ThumbnailService.instance;
  Future<String?>? _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    if (widget.doc.filePath != null) {
      _thumbnailFuture = _thumbnailService.getThumbnail(widget.doc.filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbnailFuture == null) {
      return _buildFallbackIcon();
    }

    return FutureBuilder<String?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackIcon(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: _buildFallbackIcon());
        }
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
