import 'dart:convert';
import 'dart:io';

import 'package:docscannerplus/models/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentRepository {
  static const String _storageKey = 'documents';
  static const int _trashRetentionDays = 30;

  Future<List<DocumentModel>> loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle corruption or version mismatch
      return [];
    }
  }

  /// Load only active (non-deleted) documents.
  Future<List<DocumentModel>> loadActiveDocuments() async {
    final docs = await loadDocuments();
    return docs.where((d) => !d.isDeleted).toList();
  }

  /// Load only documents in a specific folder.
  Future<List<DocumentModel>> loadDocumentsInFolder(String? folderId) async {
    final docs = await loadActiveDocuments();
    if (folderId == null) {
      // Return uncategorized documents
      return docs.where((d) => d.folderId == null).toList();
    }
    return docs.where((d) => d.folderId == folderId).toList();
  }

  /// Load only trashed documents.
  Future<List<DocumentModel>> loadTrashedDocuments() async {
    final docs = await loadDocuments();
    return docs.where((d) => d.isDeleted).toList();
  }

  Future<void> saveDocuments(List<DocumentModel> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = docs.map((d) => d.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> saveNewDocument(DocumentModel doc) async {
    final docs = await loadDocuments();
    docs.add(doc);
    await saveDocuments(docs);
  }

  /// Soft delete - move to trash instead of permanent delete.
  Future<void> moveToTrash(DocumentModel doc) async {
    final docs = await loadDocuments();
    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index != -1) {
      docs[index] = doc.moveToTrash();
      await saveDocuments(docs);
    }
  }

  /// Restore document from trash.
  Future<void> restoreFromTrash(DocumentModel doc) async {
    final docs = await loadDocuments();
    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index != -1) {
      docs[index] = doc.restoreFromTrash();
      await saveDocuments(docs);
    }
  }

  /// Permanently delete document and its file.
  Future<void> deleteDocument(DocumentModel doc) async {
    final docs = await loadDocuments();
    docs.removeWhere((d) => d.id == doc.id);
    await saveDocuments(docs);

    if (doc.filePath != null) {
      final file = File(doc.filePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Empty all items from trash permanently.
  Future<void> emptyTrash() async {
    final docs = await loadDocuments();
    final trashedDocs = docs.where((d) => d.isDeleted).toList();

    // Delete files
    for (final doc in trashedDocs) {
      if (doc.filePath != null) {
        final file = File(doc.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // Remove from list
    docs.removeWhere((d) => d.isDeleted);
    await saveDocuments(docs);
  }

  /// Auto-delete documents that have been in trash for more than 30 days.
  Future<void> cleanupExpiredTrash() async {
    final docs = await loadDocuments();
    final now = DateTime.now();
    final expiredDocs = docs.where((d) {
      if (!d.isDeleted) return false;
      final deleteDate = d.deletedAt!.add(Duration(days: _trashRetentionDays));
      return now.isAfter(deleteDate);
    }).toList();

    for (final doc in expiredDocs) {
      if (doc.filePath != null) {
        final file = File(doc.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    docs.removeWhere((d) => expiredDocs.any((e) => e.id == d.id));
    await saveDocuments(docs);
  }

  Future<void> updateDocument(DocumentModel updatedDoc) async {
    final docs = await loadDocuments();
    final index = docs.indexWhere((d) => d.id == updatedDoc.id);
    if (index != -1) {
      docs[index] = updatedDoc;
      await saveDocuments(docs);
    }
  }

  /// Move document to a folder.
  Future<void> moveToFolder(DocumentModel doc, String? folderId) async {
    final updatedDoc = doc.copyWith(
      folderId: folderId,
      clearFolderId: folderId == null,
    );
    await updateDocument(updatedDoc);
  }

  /// Get document count per folder.
  Future<Map<String?, int>> getDocumentCountByFolder() async {
    final docs = await loadActiveDocuments();
    final counts = <String?, int>{};
    for (final doc in docs) {
      counts[doc.folderId] = (counts[doc.folderId] ?? 0) + 1;
    }
    return counts;
  }
}
