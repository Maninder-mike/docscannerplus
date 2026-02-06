import 'dart:io';

import 'package:docscannerplus/add_signature_page.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/models/watermark_options.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/reorder_pages_page.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/search_page.dart';
import 'package:docscannerplus/services/pdf_service.dart';
import 'package:docscannerplus/signature_page.dart';
import 'package:docscannerplus/watermark_dialog.dart';
import 'package:docscannerplus/widgets/document_list.dart';
import 'package:docscannerplus/widgets/home_drawer.dart';
import 'package:docscannerplus/widgets/scanner_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:docscannerplus/features/home/dialogs/extracted_text_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/merge_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/rename_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/share_options_sheet.dart';
import 'package:docscannerplus/features/home/widgets/home_app_bar.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Defer logging to ensure provider is ready if needed, mostly for safety
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logScreenView(screenName: 'home_page');
    });
  }

  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  List<DocumentModel> get _allDocuments {
    return ref.read(activeDocumentsProvider).asData?.value ?? [];
  }

  Set<String> get _selectedIds => ref.read(selectionProvider);

  List<DocumentModel> get _selectedDocuments {
    final ids = _selectedIds;
    return _allDocuments.where((d) => ids.contains(d.id)).toList();
  }

  void _clearSelection() {
    ref.read(selectionProvider.notifier).clear();
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(documents: _allDocuments),
      ),
    );
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
        // Move to trash instead of permanent delete
        await _repository.moveToTrash(doc);
      }
      _clearSelection();
      // Stream updates automatically
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedDocs.length} item(s) moved to trash'),
            // Action to view trash could be added but navigation is in drawer now
            // simpler to just show message or add action that opens trash via navigator
          ),
        );
      }
    }
  }

  Future<void> _renameSelectedDocument() async {
    if (_selectedIds.length != 1) return;
    final docId = _selectedIds.first;
    // Find doc in current list
    final doc = _allDocuments.firstWhere(
      (d) => d.id == docId,
      orElse: () => _selectedDocuments.first,
    );

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => RenameDialog(initialTitle: doc.title),
    );

    if (newTitle == null || newTitle.isEmpty || newTitle == doc.title) return;

    final updatedDoc = doc.copyWith(title: newTitle);
    await _repository.updateDocument(updatedDoc);
    _clearSelection();
  }

  Future<void> _mergeSelectedDocuments() async {
    if (_selectedIds.length < 2) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => const MergeDialog(),
    );

    if (name == null || name.isEmpty) return;

    setState(() => _isLoading = true);

    // Capture selected docs before clearing
    final docsToMerge = _selectedDocuments
        .where((d) => d.filePath != null)
        .toList();

    // Sort by creation date
    docsToMerge.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _clearSelection();

    try {
      final pdfPaths = docsToMerge.map((d) => d.filePath!).toList();

      if (pdfPaths.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final service = PdfService();
      final mergedPath = await service.mergePdfs(pdfPaths, name);

      if (mergedPath != null) {
        final newDoc = DocumentModel.create(
          title: name,
          filePath: mergedPath,
          pageCount: docsToMerge.fold(0, (sum, doc) => sum + doc.pageCount),
          ocrImagePath: docsToMerge.first.ocrImagePath,
        );

        await _repository.saveNewDocument(newDoc);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Documents merged successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to merge documents')),
          );
        }
      }
    } catch (e) {
      debugPrint('Merge Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shareSelectedDocuments() {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ShareOptionsSheet(
        onSharePdf: () => _shareAsPdf(selectedDocs),
        onShareText: () => _shareAsText(selectedDocs),
        hasTextContent: selectedDocs.any(
          (d) => d.extractedText != null && d.extractedText!.isNotEmpty,
        ),
      ),
    );
  }

  Future<void> _shareAsPdf(List<DocumentModel> docs) async {
    final files = <XFile>[];
    for (final doc in docs) {
      if (doc.filePath != null) {
        files.add(XFile(doc.filePath!));
      }
    }

    if (files.isEmpty) return;
    // ignore: deprecated_member_use
    await Share.shareXFiles(files, text: 'Shared PDF documents');
    ref.read(analyticsServiceProvider).logFeatureUsed('share_pdf');
    _clearSelection();
  }

  Future<void> _shareAsText(List<DocumentModel> docs) async {
    final docsWithText = docs
        .where((d) => d.extractedText != null && d.extractedText!.isNotEmpty)
        .toList();

    if (docsWithText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No text to share')));
      }
      return;
    }

    setState(() => _isLoading = true);
    _clearSelection();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final files = <XFile>[];

      for (final doc in docsWithText) {
        final filename = '${doc.title.replaceAll(' ', '_')}.txt';
        final file = File(path.join(appDir.path, filename));
        await file.writeAsString(doc.extractedText!);
        files.add(XFile(file.path));
      }

      // ignore: deprecated_member_use
      await Share.shareXFiles(files, text: 'Shared text via DocScanner+');
      ref.read(analyticsServiceProvider).logFeatureUsed('share_text');
    } catch (e) {
      debugPrint('Share Text Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing text: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Other actions (Edit Tags, OCR, Reorder, Sign, Watermark)
  // Simplified for brevity, assume similar pattern.
  // I will include them to ensure functionality is preserved.

  Future<void> _editTags() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;

    final controller = TextEditingController(text: doc.tags.join(', '));
    final tagsString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tags'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tags (comma separated)',
            hintText: 'Work, Finance, Project',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (tagsString == null) return;
    final newTags = tagsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    await _repository.updateDocument(doc.copyWith(tags: newTags));
    _clearSelection();
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
      // prevent dismissal while loading logic runs?
      // better to use _isLoading overlay.
      // But original used dialog with circular progress.
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final imagePathToUse = doc.ocrImagePath ?? doc.filePath;
    if (imagePathToUse == null) {
      Navigator.pop(context); // Close loading dialog
      return;
    }

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final text = await ocrService.extractText(imagePathToUse);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (text != null && text.isNotEmpty) {
        final updatedDoc = doc.copyWith(extractedText: text);
        await _repository.updateDocument(updatedDoc);
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
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('OCR Error: $e')));
      }
    }
  }

  void _showExtractedTextDialog(DocumentModel doc) {
    showDialog(
      context: context,
      builder: (context) => ExtractedTextDialog(text: doc.extractedText ?? ''),
    );
  }

  Future<void> _reorderPages() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    setState(() => _isLoading = true);
    _clearSelection();

    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      if (!mounted) return;
      if (images.isEmpty) throw Exception("Could not extract pages");

      setState(() => _isLoading = false); // Stop loading to show UI

      final newOrder = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => ReorderPagesPage(imagePaths: images),
        ),
      );

      if (newOrder != null) {
        setState(() => _isLoading = true);
        final newPath = await service.imagesToPdf(newOrder, doc.title);
        if (newPath != null) {
          await _repository.updateDocument(doc.copyWith(filePath: newPath));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pages reordered successfully')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Reorder Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signDocument() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    final signature = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (context) => const SignaturePage()),
    );
    if (signature == null) return;

    _clearSelection();
    setState(() => _isLoading = true);

    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      if (images.isEmpty) throw Exception("Could not extract pages");

      setState(() => _isLoading = false);
      if (!mounted) return;

      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddSignaturePage(imagePaths: images, signatureImage: signature),
        ),
      );

      if (changed == true) {
        setState(() => _isLoading = true);
        final newPath = await service.imagesToPdf(images, doc.title);
        if (newPath != null) {
          await _repository.updateDocument(doc.copyWith(filePath: newPath));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document signed successfully')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Sign Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addWatermark() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    final options = await showDialog<WatermarkOptions>(
      context: context,
      builder: (context) => const WatermarkDialog(),
    );
    if (options == null) return;

    _clearSelection();
    setState(() => _isLoading = true);

    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      if (images.isEmpty) throw Exception("Could not extract pages");

      setState(() => _isLoading = false);
      if (!mounted) return;

      setState(() => _isLoading = true);
      final newPath = await service.imagesToPdf(
        images,
        doc.title,
        watermark: options,
      );

      if (newPath != null) {
        await _repository.updateDocument(doc.copyWith(filePath: newPath));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watermark added successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint("Watermark Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 500) {
            ref.read(documentLimitProvider.notifier).increase();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            HomeAppBar(
              onClearSelection: _clearSelection,
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onRename: _renameSelectedDocument,
              onEditTags: _editTags,
              onExtractText: _extractTextFromSelected,
              onReorderPages: _reorderPages,
              onSignDocument: _signDocument,
              onAddWatermark: _addWatermark,
              onMerge: _mergeSelectedDocuments,
              onShare: _shareSelectedDocuments,
              onDelete: _deleteSelectedDocuments,
              onSearch: _openSearch,
              isLoading: _isLoading,
            ),
            if (!_isLoading) const DocumentList(),
          ],
        ),
      ),
      floatingActionButton: isSelectionMode ? null : const ScannerFab(),
    );
  }
}
