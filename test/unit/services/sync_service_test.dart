import 'dart:io';
import 'package:flutter/services.dart';

import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/services/analytics_service.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([
  CloudRepository,
  DocumentRepository,
  AnalyticsService,
  CloudStorageService,
])
void main() {
  late MockCloudRepository mockCloudRepo;
  late MockDocumentRepository mockDocRepo;
  late MockAnalyticsService mockAnalytics;
  late MockCloudStorageService mockCloudService;
  late SyncService syncService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock PathProvider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getTemporaryDirectory') {
              return Directory.systemTemp.path;
            }
            return null;
          },
        );

    mockCloudRepo = MockCloudRepository();
    mockDocRepo = MockDocumentRepository();
    mockAnalytics = MockAnalyticsService();
    mockCloudService = MockCloudStorageService();

    // Default: Cloud is initialized and active
    when(mockCloudRepo.initialize()).thenAnswer((_) async {});
    when(mockCloudRepo.activeService).thenReturn(mockCloudService);
    when(mockCloudService.providerId).thenReturn('mock_provider');

    syncService = SyncService(
      cloudRepo: mockCloudRepo,
      docRepo: mockDocRepo,
      analyticsService: mockAnalytics,
    );
  });

  group('SyncService', () {
    test('sync should do nothing when no cloud provider is active', () async {
      when(mockCloudRepo.activeService).thenReturn(null);

      final result = await syncService.sync();

      expect(result, [0, 0]); // 0 uploaded, 0 downloaded
      verify(mockCloudRepo.initialize()).called(1);
      verifyNever(mockCloudRepo.listFiles());
    });

    test('sync should do nothing when lists are empty', () async {
      when(mockCloudRepo.listFiles()).thenAnswer((_) async => {});
      when(mockDocRepo.loadActiveDocuments()).thenAnswer((_) async => []);
      when(mockDocRepo.loadTrashedDocuments()).thenAnswer((_) async => []);

      final result = await syncService.sync();

      expect(result, [0, 0]);
      verify(mockCloudRepo.listFiles()).called(1);
      verify(mockDocRepo.loadActiveDocuments()).called(1);
      verifyNever(mockCloudRepo.uploadFile(any, any));
      verifyNever(mockCloudRepo.downloadFile(any, any));
    });

    // TODO: Add more tests for upload, download, delete scenarios once generated mocks are ready
  });
}
