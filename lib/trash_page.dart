import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class TrashPage extends ConsumerStatefulWidget {
  const TrashPage({super.key});

  @override
  ConsumerState<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends ConsumerState<TrashPage> {
  // _repository is replaced by ref.read(documentRepositoryProvider)
  List<DocumentModel> _trashedDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrashedDocuments();
  }

  Future<void> _loadTrashedDocuments() async {
    final docs = await ref
        .read(documentRepositoryProvider)
        .loadTrashedDocuments();
    // Sort by most recently deleted first
    docs.sort(
      (a, b) => (b.deletedAt ?? DateTime.now()).compareTo(
        a.deletedAt ?? DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() {
        _trashedDocuments = docs;
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreDocument(DocumentModel doc) async {
    await ref.read(documentRepositoryProvider).restoreFromTrash(doc);
    await _loadTrashedDocuments();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${doc.title}" restored')));
    }
  }

  Future<void> _permanentlyDelete(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'Permanently delete "${doc.title}"? This cannot be undone.',
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
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(documentRepositoryProvider).deleteDocument(doc);
      await _loadTrashedDocuments();
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashedDocuments.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Trash'),
        content: Text(
          'Permanently delete ${_trashedDocuments.length} items? This cannot be undone.',
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
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(documentRepositoryProvider).emptyTrash();
      await _loadTrashedDocuments();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trash emptied')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (_trashedDocuments.isNotEmpty)
            TextButton.icon(
              onPressed: _emptyTrash,
              icon: Icon(Icons.delete_forever, color: colorScheme.error),
              label: Text('Empty', style: TextStyle(color: colorScheme.error)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trashedDocuments.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildTrashList(colorScheme),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'Trash is empty',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.outline),
          ),
          const Gap(8),
          Text(
            'Deleted items will appear here for 30 days',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildTrashList(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trashedDocuments.length,
      itemBuilder: (context, index) {
        final doc = _trashedDocuments[index];
        return _buildTrashItem(context, ref, doc, colorScheme, index);
      },
    );
  }

  Widget _buildTrashItem(
    BuildContext context,
    WidgetRef ref,
    DocumentModel doc,
    ColorScheme colorScheme,
    int index,
  ) {
    final daysLeft = doc.daysUntilPermanentDelete;

    return Dismissible(
          key: ValueKey(doc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            margin: const EdgeInsets.only(bottom: 8),
            child: Icon(Icons.delete_forever, color: colorScheme.onError),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Permanently'),
                content: Text(
                  'Permanently delete "${doc.title}"? This cannot be undone.',
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
                    child: const Text('Delete Forever'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            if (mounted) {
              setState(() {
                _trashedDocuments.removeWhere((d) => d.id == doc.id);
              });
            }
            await ref.read(documentRepositoryProvider).deleteDocument(doc);
            await _loadTrashedDocuments();
          },
          child: Card.filled(
            color: colorScheme.surfaceContainer,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.picture_as_pdf, color: colorScheme.error),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Text(
                          daysLeft > 0
                              ? 'Deletes in $daysLeft days'
                              : 'Deletes today',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: daysLeft <= 3
                                    ? colorScheme.error
                                    : colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _restoreDocument(doc),
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore',
                  ),
                  IconButton(
                    onPressed: () => _permanentlyDelete(doc),
                    icon: Icon(Icons.delete_forever, color: colorScheme.error),
                    tooltip: 'Delete Forever',
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 50))
        .slideX(begin: 0.05, end: 0);
  }
}
