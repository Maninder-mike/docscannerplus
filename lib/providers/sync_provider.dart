import 'dart:async';
import 'package:docscannerplus/providers/cloud_provider.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/document_provider.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_provider.g.dart';

/// Sync state enum
enum SyncStatus { idle, syncing, error }

/// Provider for managing cloud sync with debounced auto-sync
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  Timer? _debounceTimer;
  static const _debounceDelay = Duration(seconds: 3);

  @override
  SyncStatus build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return SyncStatus.idle;
  }

  /// Schedule a sync after debounce delay.
  /// Multiple calls within the delay will reset the timer.
  void scheduleSync() {
    final cloudRepo = ref.read(cloudRepositoryProvider);

    // Only schedule if cloud is connected
    if (cloudRepo.activeService == null) {
      debugPrint('SyncController: No cloud provider, skipping auto-sync');
      return;
    }

    // Don't schedule if already syncing
    if (state == SyncStatus.syncing) {
      debugPrint('SyncController: Already syncing, will sync again after');
      return;
    }

    debugPrint(
      'SyncController: Scheduling sync in ${_debounceDelay.inSeconds}s',
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () => performSync());
  }

  /// Perform sync immediately
  Future<List<int>> performSync() async {
    final cloudRepo = ref.read(cloudRepositoryProvider);

    if (cloudRepo.activeService == null) {
      debugPrint('SyncController: No cloud provider connected');
      return [0, 0];
    }

    state = SyncStatus.syncing;

    try {
      final syncService = SyncService(
        cloudRepo: cloudRepo,
        docRepo: ref.read(documentRepositoryProvider),
        analyticsService: ref.read(analyticsServiceProvider),
      );

      final result = await syncService.sync();
      state = SyncStatus.idle;
      debugPrint('SyncController: Sync complete (+${result[0]}/-${result[1]})');
      return result;
    } catch (e) {
      debugPrint('SyncController: Sync error: $e');
      state = SyncStatus.error;
      rethrow;
    }
  }
}
