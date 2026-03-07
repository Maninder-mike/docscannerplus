import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/providers/settings_provider.dart';

final cloudRepositoryProvider = Provider<CloudRepository>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return CloudRepository(settingsRepo);
});
