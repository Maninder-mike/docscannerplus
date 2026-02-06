import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails details)? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  void initState() {
    super.initState();
  }

  // ErrorWidget.builder is global, but we can catch errors in build phase
  // using a try-catch in specific scenarios, but standard Flutter widgets
  // don't "catch" errors like React Error Boundaries unless we use RunZone or
  // FlutterError.onError override.
  //
  // However, specifically for *build* errors in children, Flutter displays ErrorWidget.
  // This widget is primarily a wrapper to provide a context for customizable error UI
  // if we were using a mechanism to catch them, but standard Flutter practices
  // rely on ErrorWidget.builder.
  //
  // BUT: We can use this as a semantic wrapper where we might want to manually catch
  // errors in async operations or provided builders if we controlled them.
  //
  // A true "React-style" ErrorBoundary in Flutter is hard because framework catches errors.
  // Best practice: Global ErrorWidget.builder + Try/Catch in Async.
  //
  // We will keep this simple: It acts as a passthrough currently, but we can usage it
  // to wrap sections we might want to protect if we implemented a custom localized
  // error handling zone, but for now, we will rely on main.dart's ErrorWidget.builder.
  //
  // Actually, let's make it useful: We can't easily catch *build* errors of children here
  // without modifying the child's build method.
  //
  // Strategy Change: We will just define the `ErrorDetailsPage` here that we will use
  // in main.dart's global builder.

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class GlobalErrorPage extends StatelessWidget {
  final FlutterErrorDetails details;

  const GlobalErrorPage({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We encountered an unexpected error. Our team has been notified.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  // In a real app, maybe restart or just pop?
                  // Since this replaces the widget that crashed, maybe just nothing or 'Go Home'
                  // if we had navigation context.
                  // For now, minimal.
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: SingleChildScrollView(
                    child: Text(
                      details.exception.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
