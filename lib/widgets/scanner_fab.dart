import 'dart:io';

import 'package:docscannerplus/filter_preview_page.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/folder_provider.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:docscannerplus/document_scanner_service.dart';
import 'package:docscannerplus/services/image_filter_service.dart';
import 'package:docscannerplus/services/performance_service.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ScannerFab extends ConsumerWidget {
  const ScannerFab({super.key});

  Future<void> _scanDocument(BuildContext context, WidgetRef ref) async {
    final service = DocumentScannerService();
    try {
      final newDoc = await PerformanceService.traceScan(() async {
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
            if (ocrImagePath != null && context.mounted) {
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
              if (selectedFilter == null) return null;
            }

            // Format: Scanned Doc yyyyMMdd
            final now = DateTime.now();
            final dateStr = DateFormat('yyyyMMdd').format(now);

            // Get current folder if any
            final currentFolderId = ref.read(selectedFolderProvider);

            final newDoc = DocumentModel.create(
              title: "Scanned Doc $dateStr",
              filePath: pdfPath,
              pageCount: 1,
              ocrImagePath: ocrImagePath,
              filterType: selectedFilter?.name,
              folderId: currentFolderId,
            );

            debugPrint(
              'ScannerFab: Saving document: ${newDoc.title}, path: ${newDoc.filePath}',
            );
            await ref.read(documentRepositoryProvider).saveNewDocument(newDoc);
            debugPrint('ScannerFab: Document saved successfully');

            // Auto-save to Files if enabled
            try {
              final autoSave = ref
                  .read(settingsRepositoryProvider)
                  .loadAutoSaveToGallery();

              if (autoSave) {
                final appDir = await getApplicationDocumentsDirectory();
                // Create a clean filename
                final safeTitle = newDoc.title.replaceAll(
                  RegExp(r'[^\w\s\-]'),
                  '',
                );
                final savePath = path.join(appDir.path, '$safeTitle.pdf');
                await File(pdfPath).copy(savePath);

                if (context.mounted) {
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
            return newDoc;
          }
        }
        return null;
      });

      debugPrint(
        'ScannerFab: Scan completed, newDoc: ${newDoc?.title ?? "null"}',
      );
      if (newDoc != null) {
        ref
            .read(analyticsServiceProvider)
            .logDocumentScanned(pageCount: newDoc.pageCount);
      }
    } catch (e) {
      debugPrint('Scan Error: $e');
    } finally {
      service.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _scanDocument(context, ref),
      label: const Text('Scan'),
      icon: const Icon(Icons.camera_alt_outlined),
    ).animate().scale(
      delay: 500.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
