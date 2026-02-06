// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(folderRepository)
const folderRepositoryProvider = FolderRepositoryProvider._();

final class FolderRepositoryProvider
    extends
        $FunctionalProvider<
          FolderRepository,
          FolderRepository,
          FolderRepository
        >
    with $Provider<FolderRepository> {
  const FolderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderRepositoryHash();

  @$internal
  @override
  $ProviderElement<FolderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderRepository create(Ref ref) {
    return folderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderRepository>(value),
    );
  }
}

String _$folderRepositoryHash() => r'08994c2f14b50c769ee09f4262bad6c2dc4b1a29';

@ProviderFor(SelectedFolder)
const selectedFolderProvider = SelectedFolderProvider._();

final class SelectedFolderProvider
    extends $NotifierProvider<SelectedFolder, String?> {
  const SelectedFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFolderHash();

  @$internal
  @override
  SelectedFolder create() => SelectedFolder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedFolderHash() => r'd08bd5e49246f11898abcce348015f382019566d';

abstract class _$SelectedFolder extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedFolderName)
const selectedFolderNameProvider = SelectedFolderNameProvider._();

final class SelectedFolderNameProvider
    extends $NotifierProvider<SelectedFolderName, String?> {
  const SelectedFolderNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFolderNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFolderNameHash();

  @$internal
  @override
  SelectedFolderName create() => SelectedFolderName();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedFolderNameHash() =>
    r'a4ead8b55690bce9f1cfd69602a1f6a9adb08b7b';

abstract class _$SelectedFolderName extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(folders)
const foldersProvider = FoldersProvider._();

final class FoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FolderModel>>,
          List<FolderModel>,
          FutureOr<List<FolderModel>>
        >
    with
        $FutureModifier<List<FolderModel>>,
        $FutureProvider<List<FolderModel>> {
  const FoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersHash();

  @$internal
  @override
  $FutureProviderElement<List<FolderModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FolderModel>> create(Ref ref) {
    return folders(ref);
  }
}

String _$foldersHash() => r'ae1599056cd35e8f65096265c40779ce23aa2b14';

@ProviderFor(folderStats)
const folderStatsProvider = FolderStatsProvider._();

final class FolderStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String?, int>>,
          Map<String?, int>,
          FutureOr<Map<String?, int>>
        >
    with
        $FutureModifier<Map<String?, int>>,
        $FutureProvider<Map<String?, int>> {
  const FolderStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String?, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String?, int>> create(Ref ref) {
    return folderStats(ref);
  }
}

String _$folderStatsHash() => r'e2a7d3313057e7767bca3d7c2aedc14ddedfeeef';
