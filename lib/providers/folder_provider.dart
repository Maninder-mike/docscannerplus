import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/repositories/folder_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_provider.g.dart';

@riverpod
FolderRepository folderRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FolderRepository(prefs);
}

@riverpod
class SelectedFolder extends _$SelectedFolder {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

@riverpod
class SelectedFolderName extends _$SelectedFolderName {
  @override
  String? build() => null;

  void set(String? name) {
    state = name;
  }
}
