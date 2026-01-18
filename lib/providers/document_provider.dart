import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the DocumentRepository instance.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

/// Streams the list of active documents from the local database.
final activeDocumentsProvider = StreamProvider.autoDispose<List<DocumentModel>>(
  (ref) async* {
    final repository = ref.watch(documentRepositoryProvider);
    yield* repository.watchActiveDocuments();
  },
);
