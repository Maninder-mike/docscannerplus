import 'package:docscannerplus/services/remote_config_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config_provider.g.dart';

@riverpod
RemoteConfigService remoteConfig(Ref ref) {
  return RemoteConfigService();
}
