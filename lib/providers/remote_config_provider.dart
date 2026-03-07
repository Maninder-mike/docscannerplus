import 'package:docscannerplus/services/remote_config_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
