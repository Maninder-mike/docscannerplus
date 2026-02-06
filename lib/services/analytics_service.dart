import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('Analytics: $name $parameters');
      }
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  // Standardized Events

  Future<void> logDocumentScanned({
    required int pageCount,
    bool isAutoCaptured = false,
  }) async {
    await logEvent(
      name: 'document_scanned',
      parameters: {
        'page_count': pageCount,
        'is_auto_captured': isAutoCaptured ? 1 : 0,
      },
    );
  }

  Future<void> logSyncCompleted({
    required int uploadedCount,
    required int downloadedCount,
    required int durationMs,
  }) async {
    await logEvent(
      name: 'sync_completed',
      parameters: {
        'uploaded_count': uploadedCount,
        'downloaded_count': downloadedCount,
        'duration_ms': durationMs,
      },
    );
  }

  Future<void> logFeatureUsed(String featureName) async {
    await logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName},
    );
  }

  Future<void> logError(String error, {String? stackTrace}) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error': error,
        'stack_trace': stackTrace?.toString().substring(0, 100) ?? '',
      },
    );
  }
}
