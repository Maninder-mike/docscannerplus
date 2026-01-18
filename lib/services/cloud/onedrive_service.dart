import 'dart:convert';
import 'dart:io';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:docscannerplus/main.dart' show appNavigatorKey;
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OneDriveService implements CloudStorageService {
  static const String _appFolderName = 'DocScanner+';

  // Credentials are now retrieved from environment variables
  // Run with: flutter run --dart-define=ONEDRIVE_CLIENT_ID=your-client-id
  static const String _clientId = String.fromEnvironment('ONEDRIVE_CLIENT_ID');
  static const String _redirectUri = String.fromEnvironment(
    'ONEDRIVE_REDIRECT_URI',
    defaultValue: 'msauth://in.co.maninder.docscannerplus/callback',
  );
  static const String _tenantId = 'common';

  AadOAuth? _oauth;
  String? _accessToken;
  String? _userEmail;
  String? _appFolderId;

  AadOAuth _getOAuth() {
    _oauth ??= AadOAuth(
      Config(
        tenant: _tenantId,
        clientId: _clientId,
        // Changed to Files.ReadWrite for full drive access (visible folder)
        scope: 'Files.ReadWrite openid profile offline_access User.Read',
        redirectUri: _redirectUri,
        navigatorKey: appNavigatorKey,
        isB2C: false,
      ),
    );
    return _oauth!;
  }

  @override
  String get providerId => 'onedrive';

  @override
  String get displayName => 'OneDrive';

  @override
  Future<bool> signIn() async {
    try {
      await _getOAuth().login();
      _accessToken = await _getOAuth().getAccessToken();
      if (_accessToken != null) {
        await _fetchUserProfile();
        await _ensureAppFolderExists();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('OneDrive Sign-in Failed: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _getOAuth().logout();
    _accessToken = null;
    _userEmail = null;
    _appFolderId = null;
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      _accessToken = await _getOAuth().getAccessToken();
      if (_accessToken != null) {
        final success = await _fetchUserProfile();
        if (success) await _ensureAppFolderExists();
        return success;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getUserEmail() async {
    return _userEmail;
  }

  Future<bool> _fetchUserProfile() async {
    if (_accessToken == null) return false;
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userEmail = data['userPrincipalName'] as String?;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Fetch User Profile Failed: $e');
      return false;
    }
  }

  /// Finds or creates the app folder in OneDrive root
  Future<void> _ensureAppFolderExists() async {
    if (_accessToken == null) {
      debugPrint('OneDrive: No access token, skipping folder check');
      return;
    }

    debugPrint('OneDrive: Checking for existing $_appFolderName folder...');

    try {
      // First, try to get children of root and look for our folder
      final listUrl = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root/children',
      );

      final listResponse = await http.get(
        listUrl,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      debugPrint('OneDrive list root response: ${listResponse.statusCode}');

      if (listResponse.statusCode == 200) {
        final data = jsonDecode(listResponse.body);
        final List items = data['value'];

        // Look for existing folder by name
        for (final item in items) {
          if (item['name'] == _appFolderName && item['folder'] != null) {
            _appFolderId = item['id'];
            debugPrint('Found existing DocScanner+ folder: $_appFolderId');
            return;
          }
        }
      } else {
        debugPrint('OneDrive list error: ${listResponse.body}');
      }

      // Create the folder
      debugPrint('OneDrive: Creating $_appFolderName folder...');
      final createUrl = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root/children',
      );

      final createResponse = await http.post(
        createUrl,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _appFolderName,
          'folder': {},
          '@microsoft.graph.conflictBehavior': 'rename',
        }),
      );

      debugPrint(
        'OneDrive create folder response: ${createResponse.statusCode}',
      );

      if (createResponse.statusCode == 201) {
        final data = jsonDecode(createResponse.body);
        _appFolderId = data['id'];
        debugPrint('Created DocScanner+ folder: $_appFolderId');
      } else {
        debugPrint('OneDrive folder creation failed: ${createResponse.body}');
      }
    } catch (e) {
      debugPrint('Failed to ensure OneDrive app folder: $e');
    }
  }

  @override
  Future<String?> uploadFile(File file, String destinationName) async {
    if (_accessToken == null) return null;

    try {
      if (_appFolderId == null) await _ensureAppFolderExists();

      // Upload to the app folder
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/items/$_appFolderId:/$destinationName:/content',
      );

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/octet-stream',
        },
        body: await file.readAsBytes(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('OneDrive Upload Success: ${data['id']}');
        return data['id'];
      } else {
        debugPrint(
          'OneDrive Upload Error: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('OneDrive Upload Failed: $e');
      return null;
    }
  }

  @override
  Future<File?> downloadFile(String cloudId, String savePath) async {
    if (_accessToken == null) return null;

    try {
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/items/$cloudId/content',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        debugPrint('OneDrive Download Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('OneDrive Download Failed: $e');
      return null;
    }
  }

  @override
  Future<void> deleteFile(String cloudId) async {
    if (_accessToken == null) return;
    try {
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/items/$cloudId',
      );
      await http.delete(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
    } catch (e) {
      debugPrint('OneDrive Delete Failed: $e');
    }
  }

  @override
  Future<Map<String, String>> listFiles() async {
    if (_accessToken == null) return {};

    try {
      if (_appFolderId == null) await _ensureAppFolderExists();
      if (_appFolderId == null) return {};

      // List files from the app folder
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/items/$_appFolderId/children',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['value'];
        final map = <String, String>{};
        for (final item in items) {
          if (item['id'] != null &&
              item['name'] != null &&
              item['deleted'] == null) {
            map[item['id']] = item['name'];
          }
        }
        return map;
      }
      return {};
    } catch (e) {
      debugPrint('OneDrive List Failed: $e');
      return {};
    }
  }
}
