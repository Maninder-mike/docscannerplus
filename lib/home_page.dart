import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:docscannerplus/document_scanner_service.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = DocumentRepository();
  final _ocrService = OcrService();
  List<DocumentModel> _documents = [];
  bool _isLoading = true;

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    final docs = await _repository.loadDocuments();
    // Sort by newest first
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    }
  }

  void _toggleSelectionMode(String docId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(docId);
    });
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedIds.contains(docId)) {
        _selectedIds.remove(docId);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(docId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  List<DocumentModel> get _selectedDocuments {
    return _documents.where((d) => _selectedIds.contains(d.id)).toList();
  }

  Future<void> _deleteSelectedDocuments() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Documents'),
        content: Text('Delete ${selectedDocs.length} selected documents?'),
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
      for (final doc in selectedDocs) {
        await _repository.deleteDocument(doc);
      }
      _clearSelection();
      await _loadDocuments();
    }
  }

  Future<void> _shareSelectedDocuments() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    final xFiles = selectedDocs
        .where((d) => d.filePath != null)
        .map((d) => XFile(d.filePath!))
        .toList();

    if (xFiles.isNotEmpty) {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        xFiles,
        text: 'Sharing ${xFiles.length} documents',
      );
      _clearSelection();
    }
  }

  Future<void> _renameSelectedDocument() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;

    final controller = TextEditingController(text: doc.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != doc.title) {
      final updatedDoc = doc.copyWith(title: newTitle);
      await _repository.updateDocument(updatedDoc);
      _clearSelection();
      await _loadDocuments();
    }
  }

  Future<void> _extractTextFromSelected() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;

    if (doc.extractedText != null) {
      _showExtractedTextDialog(doc);
      _clearSelection();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final imagePathToUse = doc.ocrImagePath ?? doc.filePath;
    if (imagePathToUse == null) {
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image source for OCR')),
        );
      }
      return;
    }

    final text = await _ocrService.extractText(imagePathToUse);
    if (!mounted) return;
    Navigator.pop(context);

    if (text != null && text.isNotEmpty) {
      final updatedDoc = doc.copyWith(extractedText: text);
      await _repository.updateDocument(updatedDoc);
      await _loadDocuments();
      if (mounted) {
        _showExtractedTextDialog(updatedDoc);
        _clearSelection();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No text found.')));
      }
    }
  }

  void _showExtractedTextDialog(DocumentModel doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Text'),
        content: SingleChildScrollView(
          child: SelectableText(doc.extractedText ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: doc.extractedText ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _isSelectionMode
                  ? '${_selectedIds.length} selected'
                  : 'DocScanner+',
            ),
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSelection,
                  )
                : null,
            floating: true,
            pinned: true,
            actions: _isSelectionMode
                ? [
                    if (_selectedIds.length == 1) ...[
                      IconButton(
                        onPressed: _renameSelectedDocument,
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: _extractTextFromSelected,
                        icon: const Icon(Icons.text_fields),
                      ),
                    ],
                    IconButton(
                      onPressed: _shareSelectedDocuments,
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: _deleteSelectedDocuments,
                      icon: const Icon(Icons.delete),
                    ),
                  ]
                : [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                  ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_documents.isEmpty)
            SliverFillRemaining(
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
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.70, // Taller for document preview feeling
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final doc = _documents[index];
                  return _buildDocumentCard(doc, index);
                }, childCount: _documents.length),
              ),
            ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _scanDocument,
              label: const Text('Scan'),
              icon: const Icon(Icons.camera_alt_outlined),
            ).animate().scale(
              delay: 500.ms,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
    );
  }

  Widget _buildDocumentCard(DocumentModel doc, int index) {
    final isSelected = _selectedIds.contains(doc.id);

    return GestureDetector(
          onLongPress: () => _toggleSelectionMode(doc.id),
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(doc.id);
            } else {
              _openDocument(doc);
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
                      Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      if (_isSelectionMode)
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
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (50 * index).ms)
        .slideY(begin: 0.1, duration: 400.ms);
  }

  Future<void> _scanDocument() async {
    final service = DocumentScannerService();
    try {
      final result = await service.scanDocument();
      if (result != null) {
        // Dynamic access to avoid compilation error if class unknown (same as before)
        final dynamic dynamicResult = result;
        String? pdfPath;
        try {
          if (dynamicResult.pdf != null) {
            pdfPath = dynamicResult.pdf.uri;
          }
        } catch (_) {}

        if (pdfPath == null) {
          try {
            if (dynamicResult.images != null &&
                (dynamicResult.images as List).isNotEmpty) {
              pdfPath = (dynamicResult.images as List).first;
            }
          } catch (_) {}
        }

        if (pdfPath != null) {
          // Format: Scanned Doc yyyyMMdd
          final now = DateTime.now();
          final dateStr = DateFormat('yyyyMMdd').format(now);

          String? ocrImagePath;
          try {
            if (dynamicResult.images != null &&
                (dynamicResult.images as List).isNotEmpty) {
              ocrImagePath = (dynamicResult.images as List).first;
            }
          } catch (_) {}

          final newDoc = DocumentModel.create(
            title: "Scanned Doc $dateStr",
            filePath: pdfPath,
            pageCount: 1,
            ocrImagePath: ocrImagePath,
          );

          await _repository.saveNewDocument(newDoc);
          await _loadDocuments(); // Refresh list associated with persistence
        }
      }
    } catch (e) {
      debugPrint('Scan Error: $e');
    } finally {
      service.dispose();
    }
  }

  Future<void> _openDocument(DocumentModel doc) async {
    if (doc.filePath != null) {
      final result = await OpenFilex.open(doc.filePath!);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('File path not found')));
      }
    }
  }
}
