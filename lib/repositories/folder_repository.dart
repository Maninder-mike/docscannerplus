import 'dart:convert';

import 'package:docscannerplus/models/folder_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting folders.
class FolderRepository {
  final SharedPreferences _prefs;

  FolderRepository(this._prefs);

  static const String _storageKey = 'folders';

  Future<List<FolderModel>> loadFolders() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((e) => FolderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveFolders(List<FolderModel> folders) async {
    final jsonList = folders.map((f) => f.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> addFolder(FolderModel folder) async {
    final folders = await loadFolders();
    folders.add(folder);
    await saveFolders(folders);
  }

  Future<void> updateFolder(FolderModel updatedFolder) async {
    final folders = await loadFolders();
    final index = folders.indexWhere((f) => f.id == updatedFolder.id);
    if (index != -1) {
      folders[index] = updatedFolder;
      await saveFolders(folders);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final folders = await loadFolders();
    folders.removeWhere((f) => f.id == folderId);
    await saveFolders(folders);
  }
}
