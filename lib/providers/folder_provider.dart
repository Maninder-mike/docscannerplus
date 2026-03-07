import 'package:docscannerplus/models/folder_model.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/repositories/folder_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FolderRepository(prefs);
});

final selectedFolderProvider = NotifierProvider<SelectedFolder, String?>(() {
  return SelectedFolder();
});

class SelectedFolder extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedFolderNameProvider =
    NotifierProvider<SelectedFolderName, String?>(() {
      return SelectedFolderName();
    });

class SelectedFolderName extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? name) {
    state = name;
  }
}

final foldersProvider = FutureProvider<List<FolderModel>>((ref) async {
  final repository = ref.watch(folderRepositoryProvider);
  return repository.loadFolders();
});

final folderStatsProvider = FutureProvider<Map<String?, int>>((ref) async {
  // Watch document changes to auto-refresh stats
  ref.watch(activeDocumentsProvider);
  final docRepo = ref.watch(documentRepositoryProvider);
  return docRepo.getDocumentCountByFolder();
});
