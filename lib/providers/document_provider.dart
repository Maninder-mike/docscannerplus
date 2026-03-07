import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/folder_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final isar = ref.watch(isarProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return DocumentRepository(isar, prefs);
});

final documentLimitProvider = NotifierProvider<DocumentLimit, int>(() {
  return DocumentLimit();
});

class DocumentLimit extends Notifier<int> {
  @override
  int build() => 20;

  void increase() {
    state += 20;
  }
}

final activeDocumentsProvider = StreamProvider<List<DocumentModel>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  final limit = ref.watch(documentLimitProvider);
  final folderId = ref.watch(selectedFolderProvider);
  final sort = ref.watch(documentSortProvider);
  final tag = ref.watch(documentTagFilterProvider);

  return repository.watchActiveDocuments(
    limit: limit,
    folderId: folderId,
    sort: sort,
    tag: tag,
  );
});
