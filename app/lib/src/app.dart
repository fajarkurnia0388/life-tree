import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/router.dart';
import 'core/theme/theme.dart';
import 'features/onboarding/onboarding_view.dart';
import 'core/widgets/error_state_widget.dart';
import 'core/widgets/loading_state_widget.dart';

class DaojiApp extends ConsumerWidget {
  const DaojiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingCompletedProvider);
    final themeModeAsync = ref.watch(appThemeModeProvider);
    final themeMode = themeModeAsync.valueOrNull ?? ThemeMode.system;

    return onboardingState.when(
      data: (completed) {
        final router = ref.watch(routerProvider);
        final dynamicTheme = ref.watch(appDynamicThemeProvider);
        final appWidget = MaterialApp.router(
          title: 'Daoji',
          locale: const Locale('id', 'ID'),
          supportedLocales: const [Locale('id', 'ID')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: dynamicTheme,
          darkTheme: CalmTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );

        return appWidget;
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: LoadingStateWidget(message: 'Menyiapkan aplikasi...'),
          ),
        ),
      ),
      error: (_, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: ErrorStateWidget(
            message: 'Gagal memuat profil.',
            onRetry: () {
              ref.invalidate(onboardingCompletedProvider);
              ref.invalidate(appThemeModeProvider);
            },
          ),
        ),
      ),
    );
  }
}
