import 'package:docscannerplus/home_page.dart';
import 'package:docscannerplus/lock_screen.dart';
import 'package:docscannerplus/onboarding_page.dart';
import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: This requires google-services.json (Android) and GoogleService-Info.plist (iOS)
  // to be present in the project options.
  try {
    await Firebase.initializeApp();

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Continue running app even if Firebase fails (e.g. missing config file)
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /// Access theme mode changer from anywhere in the app
  static void setThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?._setThemeMode(mode);
  }

  static ThemeMode getThemeMode(BuildContext context) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _settingsRepository = SettingsRepository();
  final _securityRepository = SecurityRepository();
  ThemeMode _themeMode = ThemeMode.system;

  bool _isLoading = true;
  bool _showOnboarding = false;
  bool _isLocked = false;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _checkLockOnResume();
    }
  }

  Future<void> _initialize() async {
    // Load theme
    final savedMode = await _settingsRepository.loadThemeMode();

    // Check onboarding
    final onboardingCompleted = await OnboardingPage.isCompleted();

    // Check if app lock is enabled
    final lockEnabled = await _securityRepository.isAppLockEnabled();

    if (mounted) {
      setState(() {
        _themeMode = savedMode;
        _showOnboarding = !onboardingCompleted;
        _isLocked = lockEnabled && onboardingCompleted;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLockOnResume() async {
    final lockEnabled = await _securityRepository.isAppLockEnabled();
    if (lockEnabled && mounted) {
      setState(() => _isLocked = true);
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _settingsRepository.saveThemeMode(mode);
  }

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    // Firebase Analytics Observer
    final analyticsObserver = FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'DocScanner+',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          themeMode: _themeMode,

          // Localization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            // Add more locales here
          ],

          // Analytics Tracking
          navigatorObservers: [analyticsObserver],

          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    // Show loading
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show onboarding
    if (_showOnboarding) {
      return OnboardingPage(onComplete: _onOnboardingComplete);
    }

    // Show lock screen
    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    // Show home page
    return const HomePage();
  }
}
