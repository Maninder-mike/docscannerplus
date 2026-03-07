import 'dart:convert';
import 'dart:io';
import 'package:isar_community/isar.dart';
import 'package:docscannerplus/models/document_model.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class DocumentRepository {
  static const String _storageKey = 'documents';
  static const String _migrationKey = 'isar_migrated_v1';
  static const int _trashRetentionDays = 30;

  final Isar _isar;
  final SharedPreferences _prefs;

  DocumentRepository(this._isar, this._prefs);

  Future<Isar> get _db async => _isar;

  Future<void> performMigrationIfNeeded() async {
    final migrated = _prefs.getBool(_migrationKey) ?? false;

    if (!migrated) {
      final jsonString = _prefs.getString(_storageKey);
      if (jsonString != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(jsonString);
          final docs = jsonList
              .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (docs.isNotEmpty) {
            await _isar.writeTxn(() async {
              await _isar.documentModels.putAll(docs);
            });
          }
        } catch (e) {
          debugPrint('Migration error: $e');
        }
      }
      await _prefs.setBool(_migrationKey, true);
      // Optional: Clear old data
      // await _prefs.remove(_storageKey);
    }
  }

  Future<List<DocumentModel>> loadDocuments() async {
    final isar = await _db;
    return isar.documentModels.where().findAll();
  }

  /// Load only active (non-deleted) documents.
  Future<List<DocumentModel>> loadActiveDocuments() async {
    final isar = await _db;
    return isar.documentModels
        .filter()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Watch active documents (stream updates) with filtering and sorting.
  Stream<List<DocumentModel>> watchActiveDocuments({
    int? limit,
    String? folderId,
    DocumentSortOption? sort,
    String? tag,
  }) async* {
    final isar = await _db;

    // Start with base filter for active (non-deleted) documents
    var query = isar.documentModels.filter().deletedAtIsNull();

    // Add folder filter
    if (folderId != null) {
      if (folderId == 'uncategorized') {
        query = query.folderIdIsNull();
      } else {
        query = query.folderIdEqualTo(folderId);
      }
    }

    // Add tag filter
    if (tag != null) {
      query = query.tagsElementEqualTo(tag);
    }

    // Add sorting
    QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortedQuery;
    switch (sort ?? DocumentSortOption.dateDesc) {
      case DocumentSortOption.dateDesc:
        sortedQuery = query.sortByCreatedAtDesc();
        break;
      case DocumentSortOption.dateAsc:
        sortedQuery = query.sortByCreatedAt();
        break;
      case DocumentSortOption.nameAsc:
        sortedQuery = query.sortByTitle();
        break;
      case DocumentSortOption.nameDesc:
        sortedQuery = query.sortByTitleDesc();
        break;
    }

    if (limit != null) {
      yield* sortedQuery.limit(limit).watch(fireImmediately: true);
    } else {
      yield* sortedQuery.watch(fireImmediately: true);
    }
  }

  /// Load only trashed documents.
  Future<List<DocumentModel>> loadTrashedDocuments() async {
    final isar = await _db;
    return isar.documentModels
        .filter()
        .deletedAtIsNotNull()
        .sortByDeletedAtDesc()
        .findAll();
  }

  // Deprecated: Use saveNewDocument or updateDocument
  Future<void> saveDocuments(List<DocumentModel> docs) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.documentModels.putAll(docs);
    });
  }

  Future<void> saveNewDocument(DocumentModel doc) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.documentModels.put(doc);
    });
  }

  /// Soft delete - move to trash instead of permanent delete.
  Future<void> moveToTrash(DocumentModel doc) async {
    final isar = await _db;
    final updated = doc.moveToTrash();
    await isar.writeTxn(() async {
      await isar.documentModels.put(updated);
    });
  }

  /// Restore document from trash.
  Future<void> restoreFromTrash(DocumentModel doc) async {
    final isar = await _db;
    final updated = doc.restoreFromTrash();
    await isar.writeTxn(() async {
      await isar.documentModels.put(updated);
    });
  }

  /// Permanently delete document and its file.
  Future<void> deleteDocument(DocumentModel doc) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.documentModels.filter().idEqualTo(doc.id).deleteAll();
    });

    if (doc.filePath != null) {
      final file = File(doc.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Empty all items from trash permanently.
  Future<void> emptyTrash() async {
    final isar = await _db;
    final trashedDocs = await loadTrashedDocuments();

    // Delete files
    for (final doc in trashedDocs) {
      if (doc.filePath != null) {
        final file = File(doc.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Remove from DB
    await isar.writeTxn(() async {
      await isar.documentModels.filter().deletedAtIsNotNull().deleteAll();
    });
  }

  /// Auto-delete documents that have been in trash for more than 30 days.
  Future<void> cleanupExpiredTrash() async {
    final isar = await _db;
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _trashRetentionDays));

    // Find expired
    final expiredDocs = await isar.documentModels
        .filter()
        .deletedAtLessThan(cutoffDate)
        .findAll();

    // Delete files
    for (final doc in expiredDocs) {
      if (doc.filePath != null) {
        final file = File(doc.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Delete from DB
    if (expiredDocs.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.documentModels
            .filter()
            .deletedAtLessThan(cutoffDate)
            .deleteAll();
      });
    }
  }

  Future<void> updateDocument(DocumentModel updatedDoc) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.documentModels.put(updatedDoc);
    });
  }

  /// Load all documents in a specific folder.
  Future<List<DocumentModel>> loadDocumentsInFolder(String? folderId) async {
    final isar = await _db;
    if (folderId == null || folderId == 'uncategorized') {
      return isar.documentModels.filter().folderIdIsNull().findAll();
    }
    return isar.documentModels.filter().folderIdEqualTo(folderId).findAll();
  }

  /// Move a document to a specific folder.
  Future<void> moveToFolder(DocumentModel doc, String? folderId) async {
    final isar = await _db;
    final updated = doc.copyWith(folderId: folderId);
    await isar.writeTxn(() async {
      await isar.documentModels.put(updated);
    });
  }

  /// Get counts of documents per folder.
  Future<Map<String?, int>> getDocumentCountByFolder() async {
    final isar = await _db;
    final docs = await isar.documentModels.filter().deletedAtIsNull().findAll();

    final Map<String?, int> counts = {};
    for (final doc in docs) {
      counts[doc.folderId] = (counts[doc.folderId] ?? 0) + 1;
    }
    return counts;
  }

  /// Import a document from a temporary location (e.g., downloaded from cloud).
  Future<void> importDownloadedDocument(File tmpFile, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();

      // Ensure unique filename
      var name = fileName;
      var file = File(path.join(appDir.path, name));
      var i = 1;
      while (await file.exists()) {
        final base = path.basenameWithoutExtension(fileName);
        final ext = path.extension(fileName);
        name = '$base ($i)$ext';
        file = File(path.join(appDir.path, name));
        i++;
      }

      // Copy to permanent location
      await tmpFile.copy(file.path);
      // Clean up tmp
      if (await tmpFile.exists()) {
        await tmpFile.delete();
      }

      // Create DocumentModel
      final title = path.basenameWithoutExtension(name).replaceAll('_', ' ');

      final doc = DocumentModel.create(
        title: title,
        filePath: file.path,
        pageCount: 1,
      );

      await saveNewDocument(doc);
    } catch (e) {
      debugPrint('Error importing document: $e');
      rethrow;
    }
  }
}
