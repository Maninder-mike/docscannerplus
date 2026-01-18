import 'dart:io';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart';

class GoogleDriveService implements CloudStorageService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope, // Access to files created by the app
      drive.DriveApi.driveAppdataScope, // Access to Application Data folder
    ],
  );

  drive.DriveApi? _driveApi;
  GoogleSignInAccount? _currentUser;

  @override
  String get providerId => 'google_drive';

  @override
  String get displayName => 'Google Drive';

  @override
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        await _initializeDriveApi();
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
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initializeDriveApi();
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

  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) return;
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient != null) {
        _driveApi = drive.DriveApi(httpClient);
      }
    } catch (e) {
      debugPrint('Drive API Initialization Failed: $e');
    }
  }

  @override
  Future<String?> uploadFile(File file, String destinationName) async {
    if (_driveApi == null) return null;

    try {
      final media = drive.Media(file.openRead(), file.lengthSync());
      final driveFile = drive.File()..name = destinationName
      // Save to 'appDataFolder' so it's hidden from user's main drive
      // but accessible by the app. Or use null to save to root.
      // For backup, appDataFolder is cleaner. For export, root is better.
      // Let's stick to root for now so users can see their files,
      // or a specific folder if we find/create one.
      // For simplicity, let's just upload to root for now.
      ;

      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return result.id;
    } catch (e) {
      debugPrint('Google Drive Upload Failed: $e');
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
  Future<Map<String, String>> listFiles() async {
    if (_driveApi == null) return {};

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'drive',
        q: "trashed = false", // Filter out trashed files
      );

      final map = <String, String>{};
      if (fileList.files != null) {
        for (final file in fileList.files!) {
          if (file.id != null && file.name != null) {
            map[file.id!] = file.name!;
          }
        }
      }
      return map;
    } catch (e) {
      debugPrint('Google Drive List Failed: $e');
      return {};
    }
  }
}
