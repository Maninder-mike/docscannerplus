import 'package:docscannerplus/repositories/security_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

/// Lock screen shown when app lock is enabled.
class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _securityRepo = SecurityRepository();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Attempt authentication automatically on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final success = await _securityRepo.authenticate();
      if (success) {
        widget.onUnlocked();
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Authentication failed. Tap to try again.';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.document_scanner,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const Gap(32),

                // Title
                Text(
                  'DocScanner+',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const Gap(8),

                Text(
                  'Locked',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const Gap(48),

                // Lock icon / Unlock button
                GestureDetector(
                  onTap: _isAuthenticating ? null : _authenticate,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: _isAuthenticating
                        ? const CircularProgressIndicator()
                        : Icon(
                            Icons.fingerprint,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),

                const Gap(24),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().shake(),

                if (!_isAuthenticating && _errorMessage == null)
                  Text(
                    'Tap to unlock with biometrics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
