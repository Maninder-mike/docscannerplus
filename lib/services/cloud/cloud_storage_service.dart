import 'dart:io';

/// Abstract interface for cloud storage providers
abstract class CloudStorageService {
  /// Unique identifier for the provider (e.g., 'google_drive', 'onedrive')
  String get providerId;

  /// Display name for the UI
  String get displayName;

  /// Icon asset path or IconData could be handled in UI, but this helps
  // String get iconAsset;

  /// Authenticate the user
  Future<bool> signIn();

  /// Sign out
  Future<void> signOut();

  /// Check if currently signed in
  Future<bool> isSignedIn();

  /// Get currently signed in user email/name
  Future<String?> getUserEmail();

  /// Upload a file to the app's folder in cloud
  /// Returns the cloud ID of the uploaded file
  Future<String?> uploadFile(File file, String destinationName);

  /// Download a file from cloud
  /// Returns the file saved locally
  Future<File?> downloadFile(String cloudId, String savePath);

  /// Delete a file from cloud
  Future<void> deleteFile(String cloudId);

  /// List files in the app's folder
  /// Returns map of cloudId -> fileName
  Future<Map<String, String>> listFiles();
}
