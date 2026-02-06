import 'package:docscannerplus/features/settings/pages/about_page.dart';
import 'package:docscannerplus/features/settings/pages/scanner_preferences_page.dart';
import 'package:docscannerplus/providers/cloud_provider.dart';
import 'package:docscannerplus/providers/core_providers.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:docscannerplus/repositories/cloud_repository.dart';
import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/services/cloud/cloud_storage_service.dart';
import 'package:docscannerplus/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, Object> _values = {};

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }
}

class MockCloudRepository extends Mock implements CloudRepository {
  @override
  CloudStorageService? get activeService => null;

  @override
  Future<void> initialize() async {}
}

void main() {
  late FakeSharedPreferences mockPrefs;
  late MockCloudRepository mockCloudRepo;

  setUp(() {
    mockPrefs = FakeSharedPreferences();
    mockCloudRepo = MockCloudRepository();

    PackageInfo.setMockInitialValues(
      appName: 'DocScanner+',
      packageName: 'com.example.docscannerplus',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        settingsRepositoryProvider.overrideWith(
          (ref) => SettingsRepository(mockPrefs),
        ),
        cloudRepositoryProvider.overrideWithValue(mockCloudRepo),
      ],
      child: const MaterialApp(home: SettingsPage()),
    );
  }

  testWidgets('SettingsPage renders all sections', (WidgetTester tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('Scanner Preferences'), findsOneWidget);

    // Scroll to verify About is rendered (verifies list is built)
    final aboutTile = find.byKey(const Key('settings_about_tile'));
    await tester.scrollUntilVisible(
      aboutTile,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(aboutTile, findsOneWidget);
  });

  testWidgets('Search filters settings', (WidgetTester tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final scannerTile = find.byKey(const Key('settings_scanner_prefs_tile'));
    // Ensure scanner prefs is visible (at top)
    expect(scannerTile, findsOneWidget);

    final aboutTile = find.byKey(const Key('settings_about_tile'));
    await tester.scrollUntilVisible(
      aboutTile,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(aboutTile, findsOneWidget);

    // Enter search text
    // Need to scroll back up or search bar might be off screen?
    await tester.scrollUntilVisible(
      find.byType(SearchBar),
      -500,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.enterText(find.byType(SearchBar), 'About');
    await tester.pumpAndSettle();

    // Should show About
    expect(aboutTile, findsOneWidget);
    // Scanner preferences should be hidden
    expect(scannerTile, findsNothing);
  });

  testWidgets('Navigation to Scanner Preferences', (WidgetTester tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final scannerTile = find.byKey(const Key('settings_scanner_prefs_tile'));
    // Ensure visible (it should be at top but good practice)
    await tester.scrollUntilVisible(
      scannerTile,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(scannerTile);
    await tester.pumpAndSettle();

    expect(find.byType(ScannerPreferencesPage), findsOneWidget);
    expect(find.text('Default Filter'), findsOneWidget);
  });

  testWidgets('Navigation to About Page', (WidgetTester tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final aboutTile = find.byKey(const Key('settings_about_tile'));
    await tester.scrollUntilVisible(
      aboutTile,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(aboutTile);
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Legal & Support'), findsOneWidget);
  });
}
