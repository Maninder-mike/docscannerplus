import 'package:docscannerplus/home_page.dart';
import 'package:docscannerplus/lock_screen.dart';
import 'package:docscannerplus/onboarding_page.dart';
import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:docscannerplus/repositories/settings_repository.dart';
import 'package:docscannerplus/theme.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'DocScanner+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: _buildHome(),
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
