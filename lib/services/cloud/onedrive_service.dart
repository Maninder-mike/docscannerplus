import 'dart:convert';
import 'dart:io';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OneDriveService implements CloudStorageService {
  // Credentials are now retrieved from environment variables
  static const String _clientId = String.fromEnvironment('ONEDRIVE_CLIENT_ID');
  static const String _redirectUri = String.fromEnvironment(
    'ONEDRIVE_REDIRECT_URI',
    defaultValue: 'msauth://com.example.docscannerplus/callback',
  );
  static const String _tenantId = 'common';

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  final AadOAuth _oauth = AadOAuth(
    Config(
      tenant: _tenantId,
      clientId: _clientId,
      scope:
          'Files.ReadWrite.AppFolder openid profile offline_access User.Read',
      redirectUri: _redirectUri,
      navigatorKey: _navigatorKey,
      isB2C: false,
    ),
  );

  String? _accessToken;
  String? _userEmail;

  @override
  String get providerId => 'onedrive';

  @override
  String get displayName => 'OneDrive';

  @override
  Future<bool> signIn() async {
    try {
      await _oauth.login();
      _accessToken = await _oauth.getAccessToken();
      if (_accessToken != null) {
        await _fetchUserProfile();
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
    await _oauth.logout();
    _accessToken = null;
    _userEmail = null;
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      _accessToken = await _oauth.getAccessToken();
      if (_accessToken != null) {
        // Token exists, verify/refresh by fetching profile
        final success = await _fetchUserProfile();
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

  @override
  Future<String?> uploadFile(File file, String destinationName) async {
    if (_accessToken == null) return null;

    try {
      // Small files upload (up to 4MB) simple upload.
      // For App Folder: /me/drive/special/approot
      // Endpoint: PUT /me/drive/special/approot:/<filename>:/content
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$destinationName:/content',
      );

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/octet-stream', // Generic binary
        },
        body: await file.readAsBytes(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      // GET /me/drive/items/{item-id}/content
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
      // GET /me/drive/special/approot/children
      final url = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/special/approot/children',
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
