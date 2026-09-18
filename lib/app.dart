import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/core/router/app_router.dart';
import 'package:planpal/core/theme/app_theme.dart';

/// Root application widget.
///
/// Uses [createAppRouter] (factory) so the router can watch [authProvider]
/// via Riverpod and redirect automatically on auth state changes.
class PlanPalApp extends ConsumerStatefulWidget {
  const PlanPalApp({super.key});

  @override
  ConsumerState<PlanPalApp> createState() => _PlanPalAppState();
}

class _PlanPalAppState extends ConsumerState<PlanPalApp> {
  late final _router = createAppRouter(ref);

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PlanPal',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Router ────────────────────────────────────────────────────────────
      routerConfig: _router,

      // ── Localisation ──────────────────────────────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('pt'),
      ],
    );
  }
}
