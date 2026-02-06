import 'dart:io';

import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Isar isar;
  late DocumentRepository repository;
  late SharedPreferences prefs;
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Isar core if needed (usually handled by libraries, but good for safety in tests)
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Create temp directory for Isar
    tempDir = Directory.systemTemp.createTempSync();

    // Initialize Isar
    isar = await Isar.open([DocumentModelSchema], directory: tempDir.path);

    repository = DocumentRepository(isar, prefs);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DocumentRepository Tests', () {
    test('saveNewDocument should persist document', () async {
      final doc = DocumentModel.create(title: 'Test Doc');
      await repository.saveNewDocument(doc);

      final savedDocs = await repository.loadDocuments();
      expect(savedDocs.length, 1);
      expect(savedDocs.first.id, doc.id);
      expect(savedDocs.first.title, 'Test Doc');
    });

    test('moveToTrash should set deletedAt', () async {
      final doc = DocumentModel.create(title: 'Trash Doc');
      await repository.saveNewDocument(doc);

      await repository.moveToTrash(doc);

      final activeDocs = await repository.loadActiveDocuments();
      expect(activeDocs, isEmpty);

      final trashedDocs = await repository.loadTrashedDocuments();
      expect(trashedDocs.length, 1);
      expect(trashedDocs.first.id, doc.id);
      expect(trashedDocs.first.isDeleted, true);
    });

    test('restoreFromTrash should clear deletedAt', () async {
      final doc = DocumentModel.create(title: 'Restore Doc');
      await repository.saveNewDocument(doc);
      await repository.moveToTrash(doc);

      // Verify it's in trash
      var trashed = await repository.loadTrashedDocuments();
      expect(trashed, isNotEmpty);

      // Restore
      await repository.restoreFromTrash(trashed.first);

      final activeDocs = await repository.loadActiveDocuments();
      expect(activeDocs.length, 1);
      expect(activeDocs.first.id, doc.id);

      final emptyTrash = await repository.loadTrashedDocuments();
      expect(emptyTrash, isEmpty);
    });

    test('deleteDocument should remove from DB', () async {
      final doc = DocumentModel.create(title: 'Delete Doc');
      await repository.saveNewDocument(doc);

      await repository.deleteDocument(doc);

      final allDocs = await repository.loadDocuments();
      expect(allDocs, isEmpty);
    });

    test('loadDocumentsInFolder should filter by folderId', () async {
      final folderId = 'folder_1';
      final docInFolder = DocumentModel.create(
        title: 'In Folder',
        folderId: folderId,
      );
      final docOutside = DocumentModel.create(title: 'Outside');

      await repository.saveNewDocument(docInFolder);
      await repository.saveNewDocument(docOutside);

      final folderDocs = await repository.loadDocumentsInFolder(folderId);
      expect(folderDocs.length, 1);
      expect(folderDocs.first.id, docInFolder.id);

      final rootDocs = await repository.loadDocumentsInFolder(null);
      expect(rootDocs.length, 1);
      expect(rootDocs.first.id, docOutside.id);
    });
  });
}
