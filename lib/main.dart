import 'package:docscannerplus/home_page.dart';
import 'package:docscannerplus/lock_screen.dart';
import 'package:docscannerplus/onboarding_page.dart';
import 'package:docscannerplus/repositories/security_repository.dart';

import 'package:docscannerplus/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:docscannerplus/l10n/generated/app_localizations.dart';

import 'package:docscannerplus/services/remote_config_service.dart';
import 'package:docscannerplus/services/messaging_service.dart';
import 'package:docscannerplus/services/local_notification_service.dart';
import 'package:docscannerplus/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global navigator key for OAuth flows (e.g., OneDrive)
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Initialize Remote Config
  try {
    await RemoteConfigService().initialize();
  } catch (e) {
    debugPrint("Remote Config init failed: $e");
  }

  // Initialize Messaging (FCM)
  try {
    await MessagingService().initialize();
  } catch (e) {
    debugPrint("Messaging init failed: $e");
  }

  // Welcome Notification (Local)
  try {
    final localService = LocalNotificationService();
    await localService.initialize();
    // Fire and forget, don't await the delay
    localService.checkAndShowWelcomeNotification();
  } catch (e) {
    debugPrint("Local notification init failed: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  // Security repo still local for now as it's not a global provider yet (except implicit)
  // or we could move it to provider.
  final _securityRepository = SecurityRepository();

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
    // Theme is loaded by Riverpod provider automatically.

    // Check onboarding
    final onboardingCompleted = await OnboardingPage.isCompleted();

    // Check if app lock is enabled
    final lockEnabled = await _securityRepository.isAppLockEnabled();

    if (mounted) {
      setState(() {
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

  void _onOnboardingComplete() {
    setState(() => _showOnboarding = false);
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Firebase Analytics Observer
    final analyticsObserver = FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          title: 'DocScanner+',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          themeMode: themeMode,

          // Localization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],

          // Analytics Tracking
          navigatorObservers: [analyticsObserver],

          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingPage(onComplete: _onOnboardingComplete);
    }
    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }
    return const HomePage();
  }
}
