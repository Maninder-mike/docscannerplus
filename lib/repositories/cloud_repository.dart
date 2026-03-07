import 'dart:io';
import 'package:docscannerplus/models/cloud_file_metadata.dart';

import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:docscannerplus/services/cloud/google_drive_service.dart';
import 'package:docscannerplus/services/cloud/onedrive_service.dart';
import 'package:flutter/foundation.dart';

class CloudRepository {
  final SettingsRepository _settingsRepo;
  CloudStorageService? _activeService;

  final Map<String, CloudStorageService> _services = {
    'google_drive': GoogleDriveService(),
    'onedrive': OneDriveService(),
  };

  CloudRepository(this._settingsRepo);

  Future<bool> get isEnabled async => await _settingsRepo.getCloudEnabled();

  /// Initialize and load the saved provider
  Future<void> initialize() async {
    final providerId = _settingsRepo.loadCloudProvider();
    if (providerId != null && _services.containsKey(providerId)) {
      _activeService = _services[providerId];
      // Try to silently sign in
      final success = await _activeService!.isSignedIn();
      if (!success) {
        // If silent sign-in fails, we might want to clear the active service
        // or just leave it and let the user re-auth when they try to sync.
        // For now, we'll keep it but know it's not ready.
        debugPrint('Silent sign-in failed for $providerId');
      }
    }
  }

  CloudStorageService? get activeService => _activeService;

  /// Switch to a new provider and sign in.
  /// Returns true if sign-in was successful.
  Future<bool> setProvider(String providerId) async {
    final service = _services[providerId];
    if (service == null) return false;

    // Sign out of current if different
    if (_activeService != null && _activeService!.providerId != providerId) {
      await _activeService!.signOut();
    }

    _activeService = service;
    final success = await _activeService!.signIn();

    if (success) {
      await _settingsRepo.saveCloudProvider(providerId);
    } else {
      // If sign-in failed, revert? Or just don't save.
      _activeService = null;
    }
    return success;
  }

  /// Sign out and clear active provider.
  Future<void> disconnect() async {
    if (_activeService != null) {
      await _activeService!.signOut();
      _activeService = null;
      await _settingsRepo.saveCloudProvider(null);
    }
  }

  // Proxy methods to active service

  Future<String?> uploadFile(File file, String destinationName) async {
    if (_activeService == null) return null;
    return _activeService!.uploadFile(file, destinationName);
  }

  Future<File?> downloadFile(String cloudId, String savePath) async {
    if (_activeService == null) return null;
    return _activeService!.downloadFile(cloudId, savePath);
  }

  Future<void> deleteFile(String cloudId) async {
    if (_activeService == null) return;
    return _activeService!.deleteFile(cloudId);
  }

  Future<List<CloudFileMetadata>> listFiles() async {
    if (_activeService == null) return [];
    return _activeService!.listFiles();
  }
}
