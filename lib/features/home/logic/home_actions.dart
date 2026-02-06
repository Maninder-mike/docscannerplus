import 'package:docscannerplus/add_signature_page.dart';
import 'package:docscannerplus/features/home/dialogs/extracted_text_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/merge_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/rename_dialog.dart';
import 'package:docscannerplus/features/home/dialogs/share_options_sheet.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/models/watermark_options.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/selection_provider.dart';
import 'package:docscannerplus/providers/sync_provider.dart';
import 'package:docscannerplus/reorder_pages_page.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/search_page.dart';
import 'package:docscannerplus/services/ocr_service.dart';
import 'package:docscannerplus/services/pdf_service.dart';
import 'package:docscannerplus/signature_page.dart';
import 'package:docscannerplus/watermark_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class HomeActions {
  final BuildContext context;
  final WidgetRef ref;
  final ValueChanged<bool> setLoading;

  HomeActions({
    required this.context,
    required this.ref,
    required this.setLoading,
  });

  DocumentRepository get _repository => ref.read(documentRepositoryProvider);

  Set<String> get _selectedIds => ref.read(selectionProvider);

  List<DocumentModel> get _selectedDocuments {
    final ids = _selectedIds;
    final allDocs = ref.read(activeDocumentsProvider).asData?.value ?? [];
    return allDocs.where((doc) => ids.contains(doc.id)).toList();
  }

  void clearSelection() {
    ref.read(selectionProvider.notifier).clear();
  }

  void _scheduleSync() {
    ref.read(syncControllerProvider.notifier).scheduleSync();
  }

  void openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(
          documents: ref.read(activeDocumentsProvider).asData?.value ?? [],
        ),
      ),
    );
  }

  Future<void> deleteSelectedDocuments() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Trash?'),
        content: Text(
          'Are you sure you want to move ${selectedDocs.length} document(s) to trash?',
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
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setLoading(true);
      try {
        for (final doc in selectedDocs) {
          await _repository.moveToTrash(doc);
        }
        clearSelection();
        _scheduleSync();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error moving to trash: $e')));
        }
      } finally {
        setLoading(false);
      }
    }
  }

  Future<void> renameSelectedDocument() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => RenameDialog(initialTitle: doc.title),
    );

    if (newName != null && newName.isNotEmpty && newName != doc.title) {
      try {
        await _repository.updateDocument(doc.copyWith(title: newName));
        clearSelection();
        _scheduleSync();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error renaming document: $e')),
          );
        }
      }
    }
  }

  Future<void> mergeSelectedDocuments() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.length < 2) return;

    // MergeDialog takes no args in original code
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => const MergeDialog(),
    );

    if (newName == null || newName.isEmpty) return;

    setLoading(true);
    clearSelection();

    try {
      final service = PdfService();
      // Extract images from all PDFs
      final List<String> allImages = [];

      // Sort by creation date or let user order? Original code sorted by createdAt
      selectedDocs.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final doc in selectedDocs) {
        if (doc.filePath != null) {
          final images = await service.pdfToImages(doc.filePath!);
          allImages.addAll(images);
        }
      }

      if (allImages.isEmpty) throw Exception("No pages to merge");

      // Create new PDF
      final newPdfPath = await service.imagesToPdf(allImages, newName);
      if (newPdfPath != null) {
        // Create new document model
        final newDoc = DocumentModel.create(
          title: newName,
          filePath: newPdfPath,
          pageCount: allImages.length,
          // ocrImagePath: selectedDocs.first.ocrImagePath, // Optional: copy primary thumbnail
        );

        await _repository.saveNewDocument(newDoc);
        _scheduleSync();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents merged successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint("Merge Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error merging documents: $e')));
      }
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  Future<void> shareSelectedDocuments() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ShareOptionsSheet(
        onSharePdf: () {
          _shareAsPdf(selectedDocs);
        },
        onShareText: () {
          _shareAsText(selectedDocs);
        },
        hasTextContent: selectedDocs.any(
          (d) => d.extractedText != null && d.extractedText!.isNotEmpty,
        ),
      ),
    );
  }

  Future<void> _shareAsPdf(List<DocumentModel> docs) async {
    final xfiles = docs
        .where((d) => d.filePath != null)
        .map((d) => XFile(d.filePath!))
        .toList();

    if (xfiles.isEmpty) return;

    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    await Share.shareXFiles(
      xfiles,
      text: docs.length == 1 ? docs.first.title : 'Shared documents',
      sharePositionOrigin: sharePositionOrigin,
    );
    clearSelection();
  }

  Future<void> _shareAsText(List<DocumentModel> docs) async {
    final buffer = StringBuffer();
    for (final doc in docs) {
      if (doc.extractedText != null && doc.extractedText!.isNotEmpty) {
        buffer.writeln("--- ${doc.title} ---");
        buffer.writeln(doc.extractedText);
        buffer.writeln();
      }
    }

    if (buffer.isNotEmpty) {
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.share(
        buffer.toString(),
        subject: 'Extracted Text',
        sharePositionOrigin: sharePositionOrigin,
      );
      clearSelection();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No extracted text found')),
        );
      }
    }
  }

  Future<void> editTags() async {
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
    _scheduleSync();
    clearSelection();
  }

  Future<void> extractTextFromSelected() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    setLoading(true);
    try {
      final service = OcrService();
      final text = await service.extractText(doc.filePath!);

      if (text == null) {
        if (!context.mounted) return;
        setLoading(false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No text recognized')));
        return;
      }

      // Save text to document
      await _repository.updateDocument(doc.copyWith(extractedText: text));

      if (!context.mounted) return;
      setLoading(false);

      showDialog(
        context: context,
        builder: (context) => ExtractedTextDialog(text: text),
      );
      clearSelection();
      _scheduleSync();
    } catch (e) {
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('OCR Error: $e')));
      }
    }
  }

  Future<void> reorderPages() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    setLoading(true);
    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      setLoading(false);

      if (!context.mounted) return;

      final newPaths = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => ReorderPagesPage(imagePaths: images),
        ),
      );

      if (newPaths != null) {
        setLoading(true);
        // Create new PDF from ordered images
        final newPdfPath = await service.imagesToPdf(newPaths, doc.title);

        if (newPdfPath != null) {
          await _repository.updateDocument(
            doc.copyWith(filePath: newPdfPath, pageCount: newPaths.length),
          );
          _scheduleSync();
          clearSelection();
        }
      }
    } catch (e) {
      debugPrint("Reorder error: $e");
      setLoading(false);
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  Future<void> signDocument() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    final signatureImage = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (context) => const SignaturePage()),
    );

    if (signatureImage == null) return;

    setLoading(true);
    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      setLoading(false);

      if (!context.mounted) return;

      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => AddSignaturePage(
            imagePaths: images,
            signatureImage: signatureImage,
          ),
        ),
      );

      if (success == true) {
        setLoading(true);
        // Images were modified in place? AddSignaturePage updates the file.
        // We just need to re-create the PDF.
        final newPdfPath = await service.imagesToPdf(images, doc.title);
        if (newPdfPath != null) {
          await _repository.updateDocument(doc.copyWith(filePath: newPdfPath));
          _scheduleSync();
          clearSelection();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signature added successfully')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Sign error: $e");
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  Future<void> addWatermark() async {
    if (_selectedIds.length != 1) return;
    final doc = _selectedDocuments.first;
    if (doc.filePath == null) return;

    final options = await showDialog<WatermarkOptions>(
      context: context,
      builder: (context) => const WatermarkDialog(),
    );
    if (options == null) return;

    clearSelection();
    setLoading(true);

    try {
      final service = PdfService();
      final images = await service.pdfToImages(doc.filePath!);
      if (images.isEmpty) throw Exception("Could not extract pages");

      setLoading(
        false,
      ); // Briefly pause loading to show progress? No, keep it true.
      if (!context.mounted) return;
      setLoading(true);

      final newPath = await service.imagesToPdf(
        images,
        doc.title,
        watermark: options,
      );

      if (newPath != null) {
        await _repository.updateDocument(doc.copyWith(filePath: newPath));
        _scheduleSync();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watermark added successfully')),
          );
        }
      }
    } catch (e) {
      debugPrint("Watermark Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setLoading(false);
    }
  }
}
