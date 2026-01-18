import 'dart:io';

import 'package:docscannerplus/folders_page.dart';
import 'package:docscannerplus/filter_preview_page.dart';
import 'package:docscannerplus/main.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/search_page.dart';
import 'package:docscannerplus/services/image_filter_service.dart';
import 'package:docscannerplus/services/ocr_service.dart';
import 'package:docscannerplus/services/thumbnail_service.dart';
import 'package:docscannerplus/services/pdf_service.dart';
import 'package:docscannerplus/signature_page.dart';
import 'package:docscannerplus/add_signature_page.dart';
import 'package:docscannerplus/watermark_dialog.dart';
import 'package:docscannerplus/models/watermark_options.dart';
import 'package:docscannerplus/settings_page.dart';
import 'package:docscannerplus/reorder_pages_page.dart';
import 'package:docscannerplus/trash_page.dart';
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
  final _thumbnailService = ThumbnailService.instance;
  List<DocumentModel> _documents = [];
  bool _isLoading = true;

  // Thumbnail cache: documentId -> thumbnailPath
  final Map<String, String?> _thumbnailCache = {};

  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  // Folder Filter State
  String? _selectedFolderId;
  String? _selectedFolderName;

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
    // Clean up expired trash items on app load
    await _repository.cleanupExpiredTrash();

    List<DocumentModel> docs;
    if (_selectedFolderId != null) {
      docs = await _repository.loadDocumentsInFolder(_selectedFolderId);
    } else {
      // Load all active (non-deleted) documents
      docs = await _repository.loadActiveDocuments();
    }

    // Sort by newest first
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) {
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    }
    // Generate thumbnails in background
    _generateThumbnails(docs);
  }

  Future<void> _generateThumbnails(List<DocumentModel> docs) async {
    for (final doc in docs) {
      if (doc.filePath != null && !_thumbnailCache.containsKey(doc.id)) {
        final thumbPath = await _thumbnailService.getThumbnail(doc.filePath!);
        if (mounted) {
          setState(() {
            _thumbnailCache[doc.id] = thumbPath;
          });
        }
      }
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
        // Move to trash instead of permanent delete
        await _repository.moveToTrash(doc);
      }
      _clearSelection();
      await _loadDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedDocs.length} item(s) moved to trash'),
            action: SnackBarAction(
              label: 'View Trash',
              onPressed: () => _openTrash(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _mergeSelectedDocuments() async {
    if (_selectedIds.length < 2) return;

    final controller = TextEditingController(text: 'Merged Document');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Documents'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Document Name',
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Merge'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    // Capture IDs before clearing selection
    final selectedIds = Set<String>.from(_selectedIds);
    _clearSelection();

    try {
      // Get documents to merge
      final docsToMerge = _documents
          .where((d) => selectedIds.contains(d.id) && d.filePath != null)
          .toList();

      // Sort by creation date (oldest first)
      docsToMerge.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final pdfPaths = docsToMerge.map((d) => d.filePath!).toList();

      if (pdfPaths.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
        await _loadDocuments();

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _shareSelectedDocuments() {
    if (_selectedDocuments.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export As', style: Theme.of(context).textTheme.titleLarge),
            const Gap(16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Document'),
              subtitle: const Text('Best for printing and sharing'),
              onTap: () {
                Navigator.pop(context);
                _shareAsPdf();
              },
            ),
            /*
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Images (JPG)'),
              subtitle: const Text('Best for social media'),
              onTap: () {
                Navigator.pop(context);
                _shareAsImages();
              },
            ),
            */
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Text (TXT)'),
              subtitle: const Text('Best for editing content'),
              enabled: _selectedDocuments.any(
                (d) => d.extractedText != null && d.extractedText!.isNotEmpty,
              ),
              onTap: () {
                Navigator.pop(context);
                _shareAsText();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsPdf() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    final files = <XFile>[];
    for (final doc in selectedDocs) {
      if (doc.filePath != null) {
        files.add(XFile(doc.filePath!));
      }
    }

    if (files.isEmpty) return;

    // Share using standard share sheet
    // ignore: deprecated_member_use
    await Share.shareXFiles(files, text: 'Shared PDF documents');
    _clearSelection();
  }

  Future<void> _shareAsText() async {
    final selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) return;

    // Filter docs with text
    final docsWithText = selectedDocs
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

    if (mounted) setState(() => _isLoading = true);
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

  Future<void> _renameSelectedDocument() async {
    if (_selectedIds.length != 1) return;
    final docId = _selectedIds.first;
    final doc = _documents.firstWhere((d) => d.id == docId);

    final controller = TextEditingController(text: doc.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
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
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newTitle == null || newTitle.isEmpty || newTitle == doc.title) return;

    final updatedDoc = doc.copyWith(title: newTitle);
    await _repository.updateDocument(updatedDoc);
    await _loadDocuments();
  }

  Future<void> _editTags() async {
    if (_selectedIds.length != 1) return;
    final docId = _selectedIds.first;
    final doc = _documents.firstWhere((d) => d.id == docId);

    final controller = TextEditingController(text: doc.tags.join(', '));
    final tagsString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tags'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'Work, Finance, Project',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
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

    final updatedDoc = doc.copyWith(tags: newTags);
    await _repository.updateDocument(updatedDoc);
    await _loadDocuments();
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

  Future<void> _reorderPages() async {
    if (_selectedIds.length != 1) return;
    final doc = _documents.firstWhere((d) => d.id == _selectedIds.first);

    if (doc.filePath == null) return;

    if (mounted) setState(() => _isLoading = true);
    _clearSelection(); // Clear selection before navigation to avoid UI glitches

    try {
      final service = PdfService();
      // Extract images to temp directory
      final images = await service.pdfToImages(doc.filePath!);

      if (!mounted) return;

      if (images.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not extract pages')),
        );
        return;
      }

      if (mounted) setState(() => _isLoading = false);

      final newOrder = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => ReorderPagesPage(imagePaths: images),
        ),
      );

      if (newOrder != null) {
        if (mounted) setState(() => _isLoading = true);

        // Create new PDF from reordered images
        final newPath = await service.imagesToPdf(newOrder, doc.title);

        if (newPath != null) {
          final updatedDoc = doc.copyWith(filePath: newPath);
          await _repository.updateDocument(updatedDoc);

          // Optionally delete old file if path changed and it's not needed
          // But creating a new file is safer.
          // We can delete the extracted temp images here if we want to be clean,
          // but system temp cleans up eventually.

          await _loadDocuments();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pages reordered successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save reordered PDF')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Reorder Pages Error: $e');
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
    final doc = _documents.firstWhere((d) => d.id == _selectedIds.first);
    if (doc.filePath == null) return;

    // 1. Capture Signature
    final signature = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (context) => const SignaturePage()),
    );

    if (signature == null) return;

    _clearSelection();
    if (mounted) setState(() => _isLoading = true);

    try {
      final service = PdfService();
      // 2. Extract Pages
      final images = await service.pdfToImages(doc.filePath!);

      if (!mounted) return;

      if (images.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not extract pages')),
        );
        return;
      }

      if (mounted) setState(() => _isLoading = false);

      // 3. Place Signature
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddSignaturePage(imagePaths: images, signatureImage: signature),
        ),
      );

      if (changed == true) {
        if (mounted) setState(() => _isLoading = true);

        // 4. Save new PDF
        final newPath = await service.imagesToPdf(images, doc.title);

        if (newPath != null) {
          final updatedDoc = doc.copyWith(filePath: newPath);
          await _repository.updateDocument(updatedDoc);
          await _loadDocuments();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document signed successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save signed PDF')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Sign Document Error: $e');
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
    final doc = _documents.firstWhere((d) => d.id == _selectedIds.first);
    if (doc.filePath == null) return;

    // 1. Configure Watermark
    final options = await showDialog<WatermarkOptions>(
      context: context,
      builder: (context) => const WatermarkDialog(),
    );

    if (options == null) return;

    _clearSelection();
    if (mounted) setState(() => _isLoading = true);

    try {
      final service = PdfService();
      // 2. Extract Pages
      final images = await service.pdfToImages(doc.filePath!);

      if (!mounted) return;

      if (images.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not extract pages')),
        );
        return;
      }

      if (mounted) setState(() => _isLoading = false);

      // 3. Create Watermarked PDF
      if (mounted) setState(() => _isLoading = true);

      final newPath = await service.imagesToPdf(
        images,
        doc.title,
        watermark: options,
      );

      if (newPath != null) {
        final updatedDoc = doc.copyWith(filePath: newPath);
        await _repository.updateDocument(updatedDoc);
        await _loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watermark added successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save watermarked PDF')),
          );
        }
      }
    } catch (e) {
      debugPrint('Watermark Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine current index based on route?
    // Since we navigate away for Folders/Trash, the primary destination stays 0.
    // Ideally we'd have a navigation state, but for now we'll stick to a simple visual.

    return NavigationDrawer(
      selectedIndex: 0, // Always highlight 'All Documents' when on HomePage
      onDestinationSelected: (index) {
        Navigator.pop(context); // Close drawer
        if (index == 1) _openFolders();
        if (index == 2) _openTrash();
        if (index == 3) _openSettings();
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.document_scanner,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(16),
              Text(
                'DocScanner+',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_documents.length} documents',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('All Documents'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Folders'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.delete_outline),
          selectedIcon: Icon(Icons.delete),
          label: Text('Trash'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
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
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            // floating: true, // Not used in .medium constructor
            // pinned: true, // Implicitly true for medium/large usually, but configurable
            actions: _isSelectionMode
                ? [
                    if (_selectedIds.length == 1) ...[
                      IconButton(
                        onPressed: _renameSelectedDocument,
                        icon: const Icon(Icons.edit),
                        tooltip: 'Rename',
                      ),
                      IconButton(
                        onPressed: _editTags,
                        icon: const Icon(Icons.label),
                        tooltip: 'Edit Tags',
                      ),
                      IconButton(
                        onPressed: _extractTextFromSelected,
                        icon: const Icon(Icons.text_fields),
                        tooltip: 'OCR',
                      ),
                      IconButton(
                        onPressed: _reorderPages,
                        icon: const Icon(Icons.sort),
                        tooltip: 'Reorder Pages',
                      ),
                      IconButton(
                        onPressed: _signDocument,
                        icon: const Icon(Icons.draw),
                        tooltip: 'Sign',
                      ),
                      IconButton(
                        onPressed: _addWatermark,
                        icon: const Icon(Icons.branding_watermark),
                        tooltip: 'Watermark',
                      ),
                    ],
                    if (_selectedIds.length > 1)
                      IconButton(
                        onPressed: _mergeSelectedDocuments,
                        icon: const Icon(Icons.merge_type),
                        tooltip: 'Merge',
                      ),
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
                      onPressed: () => _openSearch(),
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
          else ...[
            if (_selectedFolderId != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      InputChip(
                        label: Text(_selectedFolderName ?? 'Folder'),
                        avatar: const Icon(Icons.folder_outlined, size: 18),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _selectedFolderId = null;
                            _selectedFolderName = null;
                          });
                          _loadDocuments();
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
                      _buildThumbnail(doc),
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
          String? ocrImagePath;
          try {
            if (dynamicResult.images != null &&
                (dynamicResult.images as List).isNotEmpty) {
              ocrImagePath = (dynamicResult.images as List).first;
            }
          } catch (_) {}

          // Show filter preview if we have an image
          ImageFilterType? selectedFilter;
          if (ocrImagePath != null && mounted) {
            selectedFilter = await Navigator.push<ImageFilterType>(
              context,
              MaterialPageRoute(
                builder: (context) => FilterPreviewPage(
                  imagePath: ocrImagePath!,
                  pdfPath: pdfPath,
                ),
              ),
            );

            // User cancelled
            if (selectedFilter == null) return;
          }

          // Format: Scanned Doc yyyyMMdd
          final now = DateTime.now();
          final dateStr = DateFormat('yyyyMMdd').format(now);

          final newDoc = DocumentModel.create(
            title: "Scanned Doc $dateStr",
            filePath: pdfPath,
            pageCount: 1,
            ocrImagePath: ocrImagePath,
            filterType: selectedFilter?.name,
          );

          await _repository.saveNewDocument(newDoc);

          // Auto-save to Files if enabled
          try {
            final settingsRepo = SettingsRepository();
            final autoSave = await settingsRepo.loadAutoSaveToGallery();
            // Note: Key/Method name still refers to Gallery, but UI is updated to "Files"
            // We reuse the preference to avoid migration complexity for now.

            if (autoSave) {
              final appDir = await getApplicationDocumentsDirectory();
              // For visibility, on Android we might want /storage/emulated/0/Documents/DocScannerPlus
              // But getting permissions for that is harder.
              // getApplicationDocumentsDirectory on iOS is visible if Info.plist allows.
              // On Android it's app-private usually.
              // For "Save to Files", maybe we should try to save to a more public Documents folder if possible?
              // Let's stick to standard path_provider documents default which is safe.

              // Create a clean filename
              final safeTitle = newDoc.title.replaceAll(
                RegExp(r'[^\w\s\-]'),
                '',
              );
              final savePath = path.join(appDir.path, '$safeTitle.pdf');
              await File(pdfPath).copy(savePath);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'PDF auto-saved to: ${path.basename(savePath)}',
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint('Auto-save error: $e');
          }

          await _loadDocuments(); // Refresh list associated with persistence hiding
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

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(documents: _documents),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          currentThemeMode: MyApp.getThemeMode(context),
          onThemeModeChanged: (mode) => MyApp.setThemeMode(context, mode),
        ),
      ),
    );
  }

  void _openTrash() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrashPage()),
    ).then((_) => _loadDocuments()); // Refresh after returning
  }

  void _openFolders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          onFolderSelected: (folderId, folderName) {
            Navigator.pop(context);
            setState(() {
              _selectedFolderId = folderId;
              _selectedFolderName = folderName;
            });
            _loadDocuments();
          },
        ),
      ),
    );
  }

  Widget _buildThumbnail(DocumentModel doc) {
    final thumbnailPath = _thumbnailCache[doc.id];

    if (thumbnailPath != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Image.file(
          File(thumbnailPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        ),
      );
    }

    // Show loading or fallback
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Center(
        child: _thumbnailCache.containsKey(doc.id)
            ? _buildFallbackIcon() // Thumbnail generation failed
            : const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.picture_as_pdf,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
