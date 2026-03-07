import 'dart:io';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:collection/collection.dart';

class DocumentPreviewSheet extends ConsumerWidget {
  final String documentId;

  const DocumentPreviewSheet({super.key, required this.documentId});

  void _openDocument(BuildContext context, DocumentModel document) {
    Navigator.pop(context);
    OpenFilex.open(document.pdfPath);
  }

  void _shareDocument(BuildContext context, DocumentModel document) {
    Navigator.pop(context);
    Share.shareXFiles([
      XFile(document.pdfPath),
    ], text: 'Sharing ${document.title}');
  }

  void _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    DocumentModel document,
  ) async {
    final updatedDoc = document.copyWith(isFavorite: !document.isFavorite);
    await ref.read(documentRepositoryProvider).updateDocument(updatedDoc);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(activeDocumentsProvider);

    return docsAsync.when(
      data: (docs) {
        final document = docs.firstWhereOrNull((d) => d.id == documentId);
        if (document == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('Document not found')),
          );
        }
        return _buildContent(context, ref, document);
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(
        height: 200,
        child: Center(child: Text('Error loading document')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DocumentModel document,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                  image: document.pagePaths.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(document.pagePaths.first)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: document.pagePaths.isEmpty
                    ? const Icon(Icons.picture_as_pdf, size: 40)
                    : null,
              ),
              const Gap(16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(8),
                    Text(
                      '${document.formattedDate} • ${document.pagePaths.length} pages',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(8),
                    if (document.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: document.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              // Favorite Button
              IconButton(
                icon: Icon(
                  document.isFavorite ? Icons.star : Icons.star_border,
                  color: document.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => _toggleFavorite(context, ref, document),
              ),
            ],
          ),
          const Gap(24),
          const Divider(),
          const Gap(8),
          // Actions
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open Document'),
            onTap: () => _openDocument(context, document),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => _shareDocument(context, document),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Trigger rename dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Trigger delete confirmation
            },
          ),
          const Gap(16), // Bottom padding
        ],
      ),
    );
  }
}
