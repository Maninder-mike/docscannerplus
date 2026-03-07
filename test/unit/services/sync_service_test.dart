import 'dart:io';
import 'package:docscannerplus/models/cloud_file_metadata.dart';
import 'package:flutter/services.dart';

import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/services/analytics_service.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:docscannerplus/models/document_model.dart';
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
      when(mockCloudRepo.listFiles()).thenAnswer((_) async => []);
      when(mockDocRepo.loadActiveDocuments()).thenAnswer((_) async => []);
      when(mockDocRepo.loadTrashedDocuments()).thenAnswer((_) async => []);

      final result = await syncService.sync();

      expect(result, [0, 0]);
      verify(mockCloudRepo.listFiles()).called(1);
      verify(mockDocRepo.loadActiveDocuments()).called(1);
      verifyNever(mockCloudRepo.uploadFile(any, any));
      verifyNever(mockCloudRepo.downloadFile(any, any));
    });

    test('sync should upload local file when not in cloud', () async {
      // Create a dummy file in temp directory so File(path).existsSync() returns true
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/test_doc.pdf');
      await file.writeAsString('dummy content');

      final localDoc = DocumentModel(
        id: 'doc_1',
        title: 'Test Doc',
        createdAt: DateTime.now(),
        filePath: file.path,
      );

      when(mockCloudRepo.listFiles()).thenAnswer((_) async => []);
      when(
        mockDocRepo.loadActiveDocuments(),
      ).thenAnswer((_) async => [localDoc]);
      when(mockDocRepo.loadTrashedDocuments()).thenAnswer((_) async => []);

      // Mock upload
      when(
        mockCloudRepo.uploadFile(any, any),
      ).thenAnswer((_) async => 'new_cloud_id');
      when(mockDocRepo.saveNewDocument(any)).thenAnswer((_) async {});

      final result = await syncService.sync();

      expect(result, [1, 0]); // 1 uploaded
      verify(mockCloudRepo.uploadFile(any, any)).called(1);
      verifyNever(mockCloudRepo.downloadFile(any, any));

      // Cleanup
      if (await file.exists()) await file.delete();
    });

    test('sync should download remote file when not local', () async {
      final cloudFile = CloudFileMetadata(
        id: 'cloud_1',
        name: 'remote_doc.pdf',
        modifiedAt: DateTime.now(),
        sizeBytes: 200,
      );

      when(mockCloudRepo.listFiles()).thenAnswer((_) async => [cloudFile]);
      when(mockDocRepo.loadActiveDocuments()).thenAnswer((_) async => []);
      when(mockDocRepo.loadTrashedDocuments()).thenAnswer((_) async => []);

      // Mock download
      final tempDir = Directory.systemTemp;
      final downloadedFile = File('${tempDir.path}/remote_doc.pdf');
      // Ensure it doesn't exist before download to avoid logic skipping
      if (await downloadedFile.exists()) await downloadedFile.delete();

      when(mockCloudRepo.downloadFile(any, any)).thenAnswer((invocation) async {
        // Simulate successful download
        await downloadedFile.writeAsString('downloaded content');
        return downloadedFile;
      });
      when(mockDocRepo.saveNewDocument(any)).thenAnswer((_) async {});

      final result = await syncService.sync();

      expect(result, [0, 1]); // 1 downloaded
      verify(mockCloudRepo.downloadFile(any, any)).called(1);
      verifyNever(mockCloudRepo.uploadFile(any, any));

      // Cleanup
      if (await downloadedFile.exists()) await downloadedFile.delete();
    });
  });
}
