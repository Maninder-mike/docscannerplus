import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceService {
  // static final FirebasePerformance _performance = FirebasePerformance.instance;
  // Use a getter or lazy init if possible, or just handle potential errors in traceOperation.

  /// Trace an async operation.
  static Future<T> traceOperation<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    if (kDebugMode) {
      debugPrint('PerformanceService: Starting trace "$name"');
    }

    try {
      // Try to get instance and start trace
      // If Firebase is not initialized (e.g. in tests), this might throw.
      final performance = FirebasePerformance.instance;
      final trace = performance.newTrace(name);
      await trace.start();

      if (attributes != null) {
        attributes.forEach((key, value) {
          trace.putAttribute(key, value);
        });
      }

      try {
        final result = await operation();
        trace.putAttribute('status', 'success');
        return result;
      } catch (e) {
        trace.putAttribute('status', 'error');
        trace.putAttribute('error_type', e.runtimeType.toString());
        rethrow;
      } finally {
        await trace.stop();
        if (kDebugMode) {
          debugPrint('PerformanceService: Stopped trace "$name"');
        }
      }
    } catch (e) {
      // Fallback: If tracing fails (e.g. Firebase not init), just run the operation.
      // This ensures tests don't crash.
      if (kDebugMode) {
        debugPrint(
          'PerformanceService: Tracing skipped/failed ($e). Running operation directly.',
        );
      }
      return await operation();
    }
  }

  /// Trace app startup.
  static Future<void> traceAppStart(Future<void> Function() init) async {
    await traceOperation('app_start', init);
  }

  /// Trace document scanning.
  static Future<T> traceScan<T>(Future<T> Function() scanOperation) async {
    return await traceOperation('document_scan', scanOperation);
  }

  /// Trace OCR operation.
  static Future<T> traceOcr<T>(Future<T> Function() ocrOperation) async {
    return await traceOperation('ocr_processing', ocrOperation);
  }

  /// Trace sync operation with metrics.
  static Future<void> traceSync(
    Future<void> Function() syncOperation, {
    required int uploadedCount,
    required int downloadedCount,
  }) async {
    await traceOperation(
      'sync_operation',
      syncOperation,
      attributes: {
        'uploaded_count': uploadedCount.toString(),
        'downloaded_count': downloadedCount.toString(),
      },
    );
  }
}
