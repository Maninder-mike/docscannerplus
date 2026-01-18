import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode
              ? const Duration(minutes: 5) // Frequent updates in dev
              : const Duration(hours: 12), // Cache for 12 hours in prod
        ),
      );

      await _remoteConfig.setDefaults({
        'show_announcement': false,
        'announcement_text': 'Welcome to DocScanner+!',
        'announcement_url': '',
        'enable_high_quality_compression': true,
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized');
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  // Getters for specific config values
  bool get showAnnouncement => _remoteConfig.getBool('show_announcement');
  String get announcementText => _remoteConfig.getString('announcement_text');
  String? get announcementUrl =>
      _remoteConfig.getString('announcement_url').isEmpty
      ? null
      : _remoteConfig.getString('announcement_url');

  bool get enableHighQualityCompression =>
      _remoteConfig.getBool('enable_high_quality_compression');
}
