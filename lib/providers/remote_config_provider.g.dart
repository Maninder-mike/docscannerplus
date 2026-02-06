// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteConfig)
const remoteConfigProvider = RemoteConfigProvider._();

final class RemoteConfigProvider
    extends
        $FunctionalProvider<
          RemoteConfigService,
          RemoteConfigService,
          RemoteConfigService
        >
    with $Provider<RemoteConfigService> {
  const RemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigService create(Ref ref) {
    return remoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigService>(value),
    );
  }
}

String _$remoteConfigHash() => r'11deb0dbe71cf20e816e848699edb07897833abe';
