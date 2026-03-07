import 'dart:io';

import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/services/thumbnail_service.dart';
import 'package:docscannerplus/widgets/document_preview_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class DocumentList extends ConsumerWidget {
  const DocumentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch documents
    final activeDocsAsync = ref.watch(activeDocumentsProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return activeDocsAsync.when(
      loading: () {
        debugPrint('DocumentList: Loading...');
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      },
      error: (err, stack) {
        debugPrint('DocumentList: Error: $err');
        return SliverFillRemaining(child: Center(child: Text('Error: $err')));
      },
      data: (allDocuments) {
        debugPrint('DocumentList: Received ${allDocuments.length} documents');

        final documents = showFavoritesOnly
            ? allDocuments.where((doc) => doc.isFavorite).toList()
            : allDocuments;

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

        final isGridView = ref.watch(isGridViewProvider);

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: isGridView
              ? SliverGrid(
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
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = documents[index];
                    return DocumentListTile(doc: doc, index: index);
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

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    try {
      final updatedDoc = doc.copyWith(isFavorite: !doc.isFavorite);
      await ref.read(documentRepositoryProvider).updateDocument(updatedDoc);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite status')),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectionProvider);
    final isSelected = selectedIds.contains(doc.id);
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return Card(
          elevation: isSelected ? 2 : 0,
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onLongPress: () {
              ref.read(selectionProvider.notifier).select(doc.id);
            },
            onTap: () {
              if (isSelectionMode) {
                ref.read(selectionProvider.notifier).toggle(doc.id);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      DocumentPreviewSheet(documentId: doc.id),
                );
              }
            },
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                const Gap(4),
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                              _getFilterShortName(
                                                doc.filterType!,
                                              ),
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                          ),
                          IconButton(
                            icon: Icon(
                              doc.isFavorite ? Icons.star : Icons.star_border,
                              color: doc.isFavorite
                                  ? Colors.amber
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              size: 18,
                            ),
                            onPressed: () => _toggleFavorite(context, ref),
                            visualDensity: VisualDensity.compact,
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
        .fadeIn(delay: Duration(milliseconds: 50 * index))
        .slideY(begin: 0.1, duration: const Duration(milliseconds: 400));
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

class DocumentListTile extends ConsumerWidget {
  final DocumentModel doc;
  final int index;

  const DocumentListTile({super.key, required this.doc, required this.index});

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    try {
      final updatedDoc = doc.copyWith(isFavorite: !doc.isFavorite);
      await ref.read(documentRepositoryProvider).updateDocument(updatedDoc);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite status')),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectionProvider);
    final isSelected = selectedIds.contains(doc.id);
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return Card(
          elevation: isSelected ? 2 : 0,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onLongPress: () {
              ref.read(selectionProvider.notifier).select(doc.id);
            },
            onTap: () {
              if (isSelectionMode) {
                ref.read(selectionProvider.notifier).toggle(doc.id);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      DocumentPreviewSheet(documentId: doc.id),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 80,
                      child: Stack(
                        children: [
                          _ThumbnailWidget(doc: doc),
                          if (isSelected || isSelectionMode)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 20,
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
                  ),
                  const Gap(12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Text(
                          doc.formattedDate,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                        ),
                        const Gap(8),
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
                  ),
                  // Favorite Button Placeholder (will add logic later)
                  IconButton(
                    icon: Icon(
                      doc.isFavorite ? Icons.star : Icons.star_border,
                      color: doc.isFavorite
                          ? Colors.amber
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _toggleFavorite(context, ref),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index))
        .slideX(begin: 0.1, duration: const Duration(milliseconds: 400));
  }
}
