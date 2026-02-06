// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentRepository)
const documentRepositoryProvider = DocumentRepositoryProvider._();

final class DocumentRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentRepository,
          DocumentRepository,
          DocumentRepository
        >
    with $Provider<DocumentRepository> {
  const DocumentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepository create(Ref ref) {
    return documentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepository>(value),
    );
  }
}

String _$documentRepositoryHash() =>
    r'983a9a79b44d0d4bd47834d25c4b21459c3bca14';

@ProviderFor(DocumentLimit)
const documentLimitProvider = DocumentLimitProvider._();

final class DocumentLimitProvider
    extends $NotifierProvider<DocumentLimit, int> {
  const DocumentLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentLimitHash();

  @$internal
  @override
  DocumentLimit create() => DocumentLimit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$documentLimitHash() => r'ac9e248bd181bcfd35d50a62a2711b4afd3da3a3';

abstract class _$DocumentLimit extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(activeDocuments)
const activeDocumentsProvider = ActiveDocumentsProvider._();

final class ActiveDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DocumentModel>>,
          List<DocumentModel>,
          Stream<List<DocumentModel>>
        >
    with
        $FutureModifier<List<DocumentModel>>,
        $StreamProvider<List<DocumentModel>> {
  const ActiveDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<List<DocumentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DocumentModel>> create(Ref ref) {
    return activeDocuments(ref);
  }
}

String _$activeDocumentsHash() => r'15e60b06a03d3aa98b136462ada93ddfa163939c';
