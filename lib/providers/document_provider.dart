import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:docscannerplus/providers/core_providers.dart';

part 'document_provider.g.dart';

@riverpod
DocumentRepository documentRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return DocumentRepository(isar, prefs);
}

@riverpod
class DocumentLimit extends _$DocumentLimit {
  @override
  int build() => 20;

  void increase() {
    state += 20;
  }
}

@riverpod
Stream<List<DocumentModel>> activeDocuments(Ref ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final limit = ref.watch(documentLimitProvider);
  return repository.watchActiveDocuments(limit: limit);
}
