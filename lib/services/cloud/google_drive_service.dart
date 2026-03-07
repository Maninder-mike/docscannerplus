import 'dart:io';
import 'package:docscannerplus/models/cloud_file_metadata.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart';

class GoogleDriveService implements CloudStorageService {
  static const String _appFolderName = 'DocScanner+';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope, // Access to files created by the app
      drive.DriveApi.driveAppdataScope, // Access to Application Data folder
    ],
  );

  drive.DriveApi? _driveApi;
  GoogleSignInAccount? _currentUser;
  String? _appFolderId;

  @override
  String get providerId => 'google_drive';

  @override
  String get displayName => 'Google Drive';

  @override
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final apiSuccess = await _initializeDriveApi();
        if (!apiSuccess) return false;

        final folderSuccess = await _ensureAppFolderExists();
        if (!folderSuccess) return false;

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Google Drive Sign-in Failed: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
    _appFolderId = null;
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initializeDriveApi();
        await _ensureAppFolderExists();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getUserEmail() async {
    return _currentUser?.email;
  }

  Future<bool> _initializeDriveApi() async {
    if (_currentUser == null) return false;
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient != null) {
        _driveApi = drive.DriveApi(httpClient);
        return true;
      }
      debugPrint('Drive API Initialization: Authenticated client is null');
      return false;
    } catch (e) {
      debugPrint('Drive API Initialization Failed: $e');
      return false;
    }
  }

  /// Finds or creates the app folder in Drive
  Future<bool> _ensureAppFolderExists() async {
    if (_driveApi == null) return false;

    try {
      // Search for existing folder
      final query =
          "name = '$_appFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final fileList = await _driveApi!.files.list(q: query, spaces: 'drive');

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        _appFolderId = fileList.files!.first.id;
        debugPrint('Found existing DocScanner+ folder: $_appFolderId');
        return true;
      } else {
        // Create the folder
        final folder = drive.File()
          ..name = _appFolderName
          ..mimeType = 'application/vnd.google-apps.folder';

        final created = await _driveApi!.files.create(folder);
        _appFolderId = created.id;
        debugPrint('Created DocScanner+ folder: $_appFolderId');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to ensure app folder: $e');
      if (e is drive.DetailedApiRequestError) {
        debugPrint('Drive API Error Status: ${e.status}');
        debugPrint('Drive API Error Message: ${e.message}');
      }
      return false;
    }
  }

  @override
  Future<String?> uploadFile(File file, String destinationName) async {
    if (_driveApi == null) return null;

    try {
      // Ensure folder exists before upload
      if (_appFolderId == null) {
        final success = await _ensureAppFolderExists();
        if (!success) return null;
      }

      final media = drive.Media(file.openRead(), file.lengthSync());
      final driveFile = drive.File()
        ..name = destinationName
        ..parents = _appFolderId != null ? [_appFolderId!] : null;

      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return result.id;
    } catch (e) {
      debugPrint('Google Drive Upload Failed: $e');
      if (e is drive.DetailedApiRequestError) {
        debugPrint('Drive Upload Error Status: ${e.status}');
        debugPrint('Drive Upload Error Message: ${e.message}');
      }
      return null;
    }
  }

  @override
  Future<File?> downloadFile(String cloudId, String savePath) async {
    if (_driveApi == null) return null;

    try {
      final media =
          await _driveApi!.files.get(
                cloudId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final file = File(savePath);
      final sink = file.openWrite();
      await media.stream.pipe(sink);
      await sink.close();
      return file;
    } catch (e) {
      debugPrint('Google Drive Download Failed: $e');
      if (e is drive.DetailedApiRequestError) {
        debugPrint('Drive Download Error Status: ${e.status}');
        debugPrint('Drive Download Error Message: ${e.message}');
      }
      return null;
    }
  }

  @override
  Future<void> deleteFile(String cloudId) async {
    if (_driveApi == null) return;
    try {
      await _driveApi!.files.delete(cloudId);
    } catch (e) {
      debugPrint('Google Drive Delete Failed: $e');
    }
  }

  @override
  Future<List<CloudFileMetadata>> listFiles() async {
    if (_driveApi == null) return [];

    try {
      // Ensure folder exists
      if (_appFolderId == null) {
        final success = await _ensureAppFolderExists();
        if (!success) return [];
      }

      // List files only from our app folder
      final query = _appFolderId != null
          ? "'$_appFolderId' in parents and trashed = false"
          : "trashed = false";

      // Request specific fields for efficiency: id, name, md5Checksum, modifiedTime, size
      final fileList = await _driveApi!.files.list(
        spaces: 'drive',
        q: query,
        $fields: 'files(id, name, md5Checksum, modifiedTime, size)',
      );

      final metadataList = <CloudFileMetadata>[];
      if (fileList.files != null) {
        for (final file in fileList.files!) {
          if (file.id != null && file.name != null) {
            metadataList.add(
              CloudFileMetadata(
                id: file.id!,
                name: file.name!,
                modifiedAt: file.modifiedTime,
                contentHash: file.md5Checksum,
                sizeBytes: file.size != null ? int.tryParse(file.size!) : null,
              ),
            );
          }
        }
      }
      return metadataList;
    } catch (e) {
      debugPrint('Google Drive List Failed: $e');
      if (e is drive.DetailedApiRequestError) {
        debugPrint('Drive List Error Status: ${e.status}');
        debugPrint('Drive List Error Message: ${e.message}');
      }
      return [];
    }
  }
}
