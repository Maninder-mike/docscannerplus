// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cloudRepository)
const cloudRepositoryProvider = CloudRepositoryProvider._();

final class CloudRepositoryProvider
    extends
        $FunctionalProvider<CloudRepository, CloudRepository, CloudRepository>
    with $Provider<CloudRepository> {
  const CloudRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudRepositoryHash();

  @$internal
  @override
  $ProviderElement<CloudRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudRepository create(Ref ref) {
    return cloudRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudRepository>(value),
    );
  }
}

String _$cloudRepositoryHash() => r'53dcea8a1b0cfef71837f572a2c08fd4c5f2f01c';
