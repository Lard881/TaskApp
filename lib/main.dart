import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/app.dart';

void main() {
  // Global Flutter error handler — prevents red-screen overlays in release
  // mode and surfaces errors as snackbars where possible (Req 26.4).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In production builds, errors are logged silently.
    // The global error boundary in AppShell surfaces them as snackbars.
    debugPrint('[FlutterError] ${details.exception}');
  };

  runApp(
    // ProviderScope is the Riverpod root — all providers live inside this.
    const ProviderScope(
      child: PlanPalApp(),
    ),
  );
}
