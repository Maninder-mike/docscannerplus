import 'dart:convert';
import 'dart:io';

import 'package:docscannerplus/models/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentRepository {
  static const String _storageKey = 'documents';

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

  Future<void> updateDocument(DocumentModel updatedDoc) async {
    final docs = await loadDocuments();
    final index = docs.indexWhere((d) => d.id == updatedDoc.id);
    if (index != -1) {
      docs[index] = updatedDoc;
      await saveDocuments(docs);
    }
  }
}
