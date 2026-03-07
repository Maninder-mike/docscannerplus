import 'dart:io';
// import 'dart:convert'; // specific import not needed for crypto
import 'package:crypto/crypto.dart';

import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/services/performance_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:docscannerplus/services/analytics_service.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/models/cloud_file_metadata.dart';

class SyncService {
  final CloudRepository cloudRepo;
  final DocumentRepository docRepo;
  final AnalyticsService? analyticsService;

  SyncService({
    required this.cloudRepo,
    required this.docRepo,
    this.analyticsService,
  });

  /// Syncs documents between local storage and cloud.
  /// Returns [uploadedCount, downloadedCount].
  Future<List<int>> sync() async {
    int uploadedCount = 0;
    int downloadedCount = 0;

    await PerformanceService.traceSync(
      (() async {
            // Ensure cloud is initialized/connected
            await cloudRepo.initialize();
            if (cloudRepo.activeService == null) {
              debugPrint('SyncService: No active cloud provider.');
              return;
            }

            try {
              // 1. Fetch Lists
              // Returns complex metadata (ID, Name, Hash/ModTime) as List<CloudFileMetadata>
              final cloudFilesList = await cloudRepo.listFiles();
              final localDocs = await docRepo.loadActiveDocuments();

              // Create lookup maps for efficiency
              final cloudFilesById = {for (var f in cloudFilesList) f.id: f};
              // Note: Drive allows duplicate names, this will keep the last one.
              // Sufficient for name-based recovery.
              final cloudFilesByName = {
                for (var f in cloudFilesList) f.name: f,
              };

              debugPrint(
                'SyncService: Found ${cloudFilesList.length} cloud files and ${localDocs.length} local docs.',
              );

              // 2. Upload missing or changed local files
              uploadedCount = await _processUploads(
                localDocs,
                cloudFilesById,
                cloudFilesByName,
              );

              // 3. Download missing cloud files
              downloadedCount = await _processDownloads(
                cloudFilesList,
                localDocs,
              );

              debugPrint(
                'SyncService: Sync Complete. +$uploadedCount / +$downloadedCount',
              );

              // 4. Delete from cloud for locally trashed documents
              await _processLocalDeletions();

              // 5. Handle cloud-side deletions (files deleted remotely)
              await _processRemoteDeletions(localDocs, cloudFilesById);
            } catch (e) {
              debugPrint('SyncService: Error during sync: $e');
              rethrow;
            }
          })
          as Future<void> Function(),
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
    );

    if (analyticsService != null) {
      await analyticsService!.logEvent(
        name: 'sync_completed',
        parameters: {
          'uploaded_count': uploadedCount,
          'downloaded_count': downloadedCount,
          'provider': cloudRepo.activeService?.providerId ?? 'search_none',
        },
      );
    }

    return [uploadedCount, downloadedCount];
  }

  Future<int> _processUploads(
    List<DocumentModel> localDocs,
    Map<String, CloudFileMetadata> cloudFilesById,
    Map<String, CloudFileMetadata> cloudFilesByName,
  ) async {
    int count = 0;
    for (final doc in localDocs) {
      if (doc.filePath == null) continue;

      final file = File(doc.filePath!);
      if (!await file.exists()) continue;

      // Calculate hash to check for changes
      final currentHash = await _calculateFileHash(file);
      final isChanged = doc.contentHash != currentHash;

      // Check if already synced and unchanged
      if (doc.cloudFileId != null && !isChanged) {
        // Verify if it still exists in cloud map
        if (cloudFilesById.containsKey(doc.cloudFileId)) {
          debugPrint(
            'SyncService: Doc ${doc.title} unchanged and in cloud. Skipping.',
          );
          continue;
        } else {
          // cloudFileId exists but not in cloud - file was deleted remotely
          // Skip uploading and let step 5 handle moving to trash
          debugPrint(
            'SyncService: Doc ${doc.title} was deleted from cloud. Skipping upload.',
          );
          continue;
        }
      }

      final fileName = path.basename(doc.filePath!);

      // Duplicate check by name (fallback if cloudFileId not set)
      String? existingCloudId;
      if (doc.cloudFileId == null) {
        if (cloudFilesByName.containsKey(fileName)) {
          existingCloudId = cloudFilesByName[fileName]?.id;
        }
      }

      if (doc.cloudFileId == null && existingCloudId != null && !isChanged) {
        // It exists in cloud, we just lost the link. Link it back.
        debugPrint(
          'SyncService: Relinking ${doc.title} to cloud ID $existingCloudId',
        );
        await docRepo.updateDocument(
          doc.copyWith(
            cloudFileId: existingCloudId,
            contentHash: currentHash,
            lastSyncedAt: DateTime.now(),
          ),
        );
        continue;
      }

      // Upload if:
      // 1. Not in cloud (no cloudFileId and not found by name)
      // 2. Content changed (isChanged is true)
      debugPrint(
        'SyncService: Uploading $fileName (Reason: ${isChanged ? 'Changed' : 'New'})...',
      );

      final cloudId = await cloudRepo.uploadFile(file, fileName);

      if (cloudId != null) {
        await docRepo.updateDocument(
          doc.copyWith(
            cloudFileId: cloudId,
            contentHash: currentHash,
            lastSyncedAt: DateTime.now(),
          ),
        );
        count++;
      }
    }
    return count;
  }

  Future<int> _processDownloads(
    List<CloudFileMetadata> cloudFiles,
    List<DocumentModel> localDocs,
  ) async {
    int count = 0;
    final tmpDir = await getTemporaryDirectory();

    for (final cloudFile in cloudFiles) {
      final cloudId = cloudFile.id;
      final cloudName = cloudFile.name;

      if (!cloudName.toLowerCase().endsWith('.pdf')) continue;

      // Check if we have it locally (by ID first, then name)
      final alreadyHave = localDocs.any(
        (d) =>
            d.cloudFileId == cloudId ||
            (d.filePath != null && path.basename(d.filePath!) == cloudName),
      );

      if (!alreadyHave) {
        debugPrint('SyncService: Downloading $cloudName...');
        final tmpPath = path.join(tmpDir.path, 'sync_tmp_$cloudName');
        final downloadedFile = await cloudRepo.downloadFile(cloudId, tmpPath);

        if (downloadedFile != null) {
          await docRepo.importDownloadedDocument(downloadedFile, cloudName);
          // Metadata update for the new doc
          // we assume importDownloadedDocument handles creation.
          // In next sync, it will be linked by name.
          count++;
        }
      }
    }
    return count;
  }

  Future<void> _processLocalDeletions() async {
    final trashedDocs = await docRepo.loadTrashedDocuments();
    for (final doc in trashedDocs) {
      if (doc.cloudFileId != null) {
        debugPrint('SyncService: Deleting ${doc.title} from cloud...');
        await cloudRepo.deleteFile(doc.cloudFileId!);
        // Clear cloud reference after deletion
        await docRepo.updateDocument(
          doc.copyWith(clearCloudFileId: true, lastSyncedAt: DateTime.now()),
        );
      }
    }
  }

  Future<void> _processRemoteDeletions(
    List<DocumentModel> localDocs,
    Map<String, CloudFileMetadata> cloudFilesById,
  ) async {
    for (final doc in localDocs) {
      if (doc.cloudFileId != null &&
          !cloudFilesById.containsKey(doc.cloudFileId)) {
        // File was in cloud but now it's gone - deleted remotely
        debugPrint(
          'SyncService: ${doc.title} deleted from cloud, moving to trash...',
        );
        await docRepo.moveToTrash(doc);
      }
    }
  }

  Future<String> _calculateFileHash(File file) async {
    // SHA256 is good for collision resistance
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}
