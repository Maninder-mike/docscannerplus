import 'dart:io';

import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SyncService {
  final CloudRepository _cloudRepo;
  final DocumentRepository _docRepo;

  SyncService({CloudRepository? cloudRepo, DocumentRepository? docRepo})
    : _cloudRepo = cloudRepo ?? CloudRepository(),
      _docRepo = docRepo ?? DocumentRepository();

  /// Perform a full sync (Upload missing to cloud, Download missing to local).
  /// Returns count of [uploaded, downloaded].
  Future<List<int>> sync() async {
    // Ensure cloud is initialized/connected
    if (_cloudRepo.activeService == null) {
      await _cloudRepo.initialize();
      if (_cloudRepo.activeService == null) {
        debugPrint('SyncService: No active cloud provider.');
        return [0, 0];
      }
    }

    try {
      int uploaded = 0;
      int downloaded = 0;

      // 1. Fetch Lists
      final cloudFiles = await _cloudRepo.listFiles(); // ID -> Name
      final localDocs = await _docRepo.loadActiveDocuments();

      debugPrint(
        'SyncService: Found ${cloudFiles.length} cloud files and ${localDocs.length} local docs.',
      );

      // 2. Upload missing local files
      for (final doc in localDocs) {
        debugPrint(
          'SyncService: Checking doc ${doc.id} - filePath: ${doc.filePath}',
        );

        if (doc.filePath == null) {
          debugPrint('SyncService: Skipping doc ${doc.id} - no filePath');
          continue;
        }

        final file = File(doc.filePath!);
        if (!await file.exists()) {
          debugPrint(
            'SyncService: Skipping doc ${doc.id} - file does not exist',
          );
          continue;
        }

        final fileName = path.basename(doc.filePath!);
        debugPrint('SyncService: Doc filename: $fileName');

        // Simple check: exists in cloud by name?
        if (!cloudFiles.values.contains(fileName)) {
          debugPrint('SyncService: Uploading $fileName...');
          final result = await _cloudRepo.uploadFile(file, fileName);
          debugPrint('SyncService: Upload result: $result');
          uploaded++;
        } else {
          debugPrint('SyncService: $fileName already in cloud, skipping');
        }
      }

      // 3. Download missing cloud files
      // We assume any PDF in the app folder is a doc we want
      final tmpDir = await getTemporaryDirectory();

      for (final entry in cloudFiles.entries) {
        final cloudId = entry.key;
        final cloudName = entry.value;

        // Skip non-pdf/zip if necessary, but assuming app folder contains only relevant stuff
        if (!cloudName.toLowerCase().endsWith('.pdf')) continue;

        // Check if we have it locally matching by filename
        // This is a naive check. A better way would be storing cloud ID in DocumentModel.
        // But for "Simple Backup", this suffices.
        final existsLocally = localDocs.any((d) {
          if (d.filePath == null) return false;
          return path.basename(d.filePath!) == cloudName;
        });

        if (!existsLocally) {
          debugPrint('SyncService: Downloading $cloudName...');
          final tmpPath = path.join(tmpDir.path, 'sync_tmp_$cloudName');
          final downloadedFile = await _cloudRepo.downloadFile(
            cloudId,
            tmpPath,
          );

          if (downloadedFile != null) {
            await _docRepo.importDownloadedDocument(downloadedFile, cloudName);
            downloaded++;
          }
        }
      }

      debugPrint('SyncService: Sync Complete. +$uploaded / +$downloaded');
      return [uploaded, downloaded];
    } catch (e) {
      debugPrint('SyncService: Error during sync: $e');
      rethrow;
    }
  }
}
