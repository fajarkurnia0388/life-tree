import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/router.dart';
import 'core/theme/theme.dart';
import 'features/onboarding/onboarding_view.dart';

class LifeTreeApp extends ConsumerWidget {
  const LifeTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingCompletedProvider);
    final themeModeAsync = ref.watch(appThemeModeProvider);
    final themeMode = themeModeAsync.valueOrNull ?? ThemeMode.system;

    return onboardingState.when(
      data: (completed) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'LifeTree',
          theme: CalmTheme.lightTheme,
          darkTheme: CalmTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('Gagal memuat profil: $err'),
          ),
        ),
      ),
    );
  }
}
