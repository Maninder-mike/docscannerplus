// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DocScanner+';

  @override
  String get homeTitle => 'Documents';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchHint => 'Search documents...';

  @override
  String get emptyDocs => 'No documents yet. Tap + to scan!';

  @override
  String get autoSavePdf => 'Auto-Save PDF to Files';

  @override
  String get autoSavePdfSubtitle =>
      'Automatically save scans as PDF to storage';

  @override
  String get defaultFilter => 'Default Filter';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';
}
