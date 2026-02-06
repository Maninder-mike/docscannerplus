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
              // TODO: Ideally listFiles should return complex metadata (ID, Name, Hash/ModTime)
              // Current implementation only returns ID -> Name
              final cloudFiles = await cloudRepo.listFiles(); // ID -> Name
              final localDocs = await docRepo.loadActiveDocuments();

              debugPrint(
                'SyncService: Found ${cloudFiles.length} cloud files and ${localDocs.length} local docs.',
              );

              // 2. Upload missing or changed local files
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
                  if (cloudFiles.containsKey(doc.cloudFileId)) {
                    debugPrint(
                      'SyncService: Doc ${doc.title} unchanged and in cloud. Skipping.',
                    );
                    continue;
                  }
                }

                final fileName = path.basename(doc.filePath!);

                // Duplicate check by name (fallback if cloudFileId not set)
                String? existingCloudId;
                if (doc.cloudFileId == null) {
                  // Find key by value (name) - inefficient but simple for now
                  for (var entry in cloudFiles.entries) {
                    if (entry.value == fileName) {
                      existingCloudId = entry.key;
                      break;
                    }
                  }
                }

                if (doc.cloudFileId == null &&
                    existingCloudId != null &&
                    !isChanged) {
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
                  uploadedCount++;
                }
              }

              // 3. Download missing cloud files
              final tmpDir = await getTemporaryDirectory();

              for (final entry in cloudFiles.entries) {
                final cloudId = entry.key;
                final cloudName = entry.value;

                if (!cloudName.toLowerCase().endsWith('.pdf')) continue;

                // Check if we have it locally (by ID first, then name)
                final alreadyHave = localDocs.any(
                  (d) =>
                      d.cloudFileId == cloudId ||
                      (d.filePath != null &&
                          path.basename(d.filePath!) == cloudName),
                );

                if (!alreadyHave) {
                  debugPrint('SyncService: Downloading $cloudName...');
                  final tmpPath = path.join(tmpDir.path, 'sync_tmp_$cloudName');
                  final downloadedFile = await cloudRepo.downloadFile(
                    cloudId,
                    tmpPath,
                  );

                  if (downloadedFile != null) {
                    await docRepo.importDownloadedDocument(
                      downloadedFile,
                      cloudName,
                    );
                    // Metadata update for the new doc
                    // We need doc ID to update metadata immediately.
                    // For now, next sync cycle will link it via name match.

                    downloadedCount++;
                  }
                }
              }

              debugPrint(
                'SyncService: Sync Complete. +$uploadedCount / +$downloadedCount',
              );
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

  Future<String> _calculateFileHash(File file) async {
    // SHA256 is good for collision resistance
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}
