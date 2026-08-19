import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/core/router/app_router.dart';
import 'package:planpal/core/theme/app_theme.dart';

/// Root application widget.
///
/// Watches [themeModeProvider] so only the root rebuilds on theme change
/// (Req 21.5). Wires go_router, theme, and localization delegates.
class PlanPalApp extends ConsumerWidget {
  const PlanPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PlanPal',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Router ─────────────────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Localisation ───────────────────────────────────────────────────────
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
