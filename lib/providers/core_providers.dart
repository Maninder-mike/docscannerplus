import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docscannerplus/services/ocr_service.dart';
import 'package:docscannerplus/services/analytics_service.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
PackageInfo packageInfo(Ref ref) {
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  throw UnimplementedError();
}

@riverpod
OcrService ocrService(Ref ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  return AnalyticsService();
}
