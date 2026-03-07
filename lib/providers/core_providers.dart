import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docscannerplus/services/ocr_service.dart';
import 'package:docscannerplus/services/analytics_service.dart';
import 'package:docscannerplus/models/document_model.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider not initialized');
});

final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError('packageInfoProvider not initialized');
});

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider not initialized');
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Phase 5 UI State Providers
final isGridViewProvider = StateProvider<bool>((ref) => true);

final documentSortProvider = StateProvider<DocumentSortOption>(
  (ref) => DocumentSortOption.dateDesc,
);

final documentTagFilterProvider = StateProvider<String?>((ref) => null);

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);
