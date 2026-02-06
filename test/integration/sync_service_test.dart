import 'dart:io';
import 'package:docscannerplus/models/document_model.dart';
import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/document_repository.dart';
import 'package:docscannerplus/services/sync_service.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([CloudRepository, CloudStorageService])
import 'sync_service_test.mocks.dart';

// Mock PathProvider
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;
  final Directory appDocDir;

  MockPathProviderPlatform(this.tempDir, this.appDocDir);

  @override
  Future<String?> getTemporaryPath() async => tempDir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => appDocDir.path;

  // Implement other methods if needed, returning tempDir by default
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCloudRepository mockCloudRepo;
  late MockCloudStorageService mockCloudService;
  late DocumentRepository docRepo;
  late SyncService syncService;
  late Isar isar;
  late Directory tempDir;
  late Directory appDocDir;

  setUp(() async {
    // Setup Filesystem
    tempDir = Directory.systemTemp.createTempSync('sync_test_temp');
    appDocDir = Directory.systemTemp.createTempSync('sync_test_docs');

    // Mock PathProvider
    PathProviderPlatform.instance = MockPathProviderPlatform(
      tempDir,
      appDocDir,
    );

    // Setup DB
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open([DocumentModelSchema], directory: tempDir.path);
    docRepo = DocumentRepository(isar, prefs);

    // Setup Cloud Repo Mock
    mockCloudRepo = MockCloudRepository();
    mockCloudService = MockCloudStorageService();
    // Default mocks
    when(mockCloudRepo.activeService).thenReturn(mockCloudService);
    when(mockCloudRepo.initialize()).thenAnswer((_) async {});

    syncService = SyncService(cloudRepo: mockCloudRepo, docRepo: docRepo);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    if (appDocDir.existsSync()) appDocDir.deleteSync(recursive: true);
  });

  test('sync should upload missing local file', () async {
    // 1. Create a local document file
    final testFile = File(path.join(appDocDir.path, 'local_doc.pdf'));
    await testFile.writeAsString('test content');

    final doc = DocumentModel.create(
      title: 'Local Doc',
      filePath: testFile.path,
    );
    await docRepo.saveNewDocument(doc);

    // 2. Mock cloud state: No files in cloud
    when(mockCloudRepo.listFiles()).thenAnswer((_) async => {});
    // Mock upload
    when(
      mockCloudRepo.uploadFile(any, any),
    ).thenAnswer((_) async => 'cloud_id_123');

    // 3. Run Sync
    final result = await syncService.sync();

    // 4. Assert
    expect(result[0], 1); // 1 uploaded
    verify(mockCloudRepo.uploadFile(any, 'local_doc.pdf')).called(1);

    // Verify local doc updated with cloudId
    final updatedDocs = await docRepo.loadActiveDocuments();
    expect(updatedDocs.first.cloudFileId, 'cloud_id_123');
    expect(updatedDocs.first.lastSyncedAt, isNotNull);
  });

  test('sync should download missing cloud file', () async {
    // 1. Mock cloud state: One file
    when(
      mockCloudRepo.listFiles(),
    ).thenAnswer((_) async => {'cloud_id_456': 'cloud_doc.pdf'});

    // Mock download
    when(mockCloudRepo.downloadFile(any, any)).thenAnswer((invocation) async {
      final String savePath = invocation.positionalArguments[1];
      final file = File(savePath);
      await file.writeAsString('downloaded content');
      return file;
    });

    // 2. Run Sync
    final result = await syncService.sync();

    // 3. Assert
    expect(result[1], 1); // 1 downloaded
    verify(mockCloudRepo.downloadFile('cloud_id_456', any)).called(1);

    final docs = await docRepo.loadActiveDocuments();
    expect(docs.length, 1);
    expect(
      docs.first.title,
      'cloud doc',
    ); // "cloud_doc" -> "cloud doc" (name sanitization)
  });
}
