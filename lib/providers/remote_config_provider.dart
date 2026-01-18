import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docscannerplus/services/remote_config_service.dart';

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
