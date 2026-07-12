import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/navigation/main_navigation_shell.dart';
import '../../features/journal/journal_lite_view.dart';
import '../../features/thinking_canvas/thinking_canvas_lite_view.dart';
import '../../features/thinking_canvas/widgets/mind_map_canvas_view.dart';
import '../../features/thinking_canvas/domain/mind_map_model.dart';
import '../../features/safety/safety_card_view.dart';
import '../../features/habit/add_habit_view.dart';
import '../../features/marketplace/marketplace_view.dart';
import '../../features/weekly_pulse/weekly_pulse_view.dart';
import '../../features/decision_journal/decision_journal_view.dart';
import '../../features/value_compass/value_mirror_intro_view.dart';
import '../../features/value_compass/value_mirror_session_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<AsyncValue<bool>>(
    const AsyncLoading(),
  );

  ref.listen<AsyncValue<bool>>(onboardingCompletedProvider, (previous, next) {
    refreshListenable.value = next;
  }, fireImmediately: true);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final onboardingCompleted = refreshListenable.value;
      final value = onboardingCompleted.valueOrNull;
      if (value == null) return null;

      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!value && !isGoingToOnboarding) {
        // User has not finished onboarding, force them to Onboarding
        return '/onboarding';
      }

      if (isGoingToOnboarding && value) {
        // Onboarding already finished, redirect from onboarding to dashboard
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationShell(),
      ),
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalLiteView(),
      ),
      GoRoute(
        path: '/thinking-canvas',
        builder: (context, state) => const ThinkingCanvasLiteView(),
        routes: [
          GoRoute(
            path: 'mind-map',
            builder: (context, state) {
              final extra = state.extra;
              List<MindMapNode> initial = const [];
              if (extra is List<MindMapNode>) {
                initial = extra;
              } else if (extra is Map && extra['nodes'] is List<MindMapNode>) {
                initial = extra['nodes'] as List<MindMapNode>;
              }
              return MindMapCanvasView(
                initialNodes: initial,
                onSaved: (_) {
                  // Pop value is primary; onSaved kept for back-compat call sites.
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/safety',
        builder: (context, state) => const SafetyCardView(),
      ),
      GoRoute(
        path: '/add-habit',
        builder: (context, state) {
          final habitId = state.uri.queryParameters['habitId'];
          final domain = state.uri.queryParameters['domain'];
          return AddHabitView(habitId: habitId, initialDomainTag: domain);
        },
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const MarketplaceView(),
      ),
      GoRoute(
        path: '/weekly-pulse',
        builder: (context, state) => const WeeklyPulseView(),
      ),
      GoRoute(
        path: '/decision-journal',
        builder: (context, state) => const DecisionJournalView(),
      ),
      GoRoute(
        path: '/value-mirror',
        builder: (context, state) => const ValueMirrorIntroView(),
        routes: [
          GoRoute(
            path: 'session',
            builder: (context, state) => const ValueMirrorSessionView(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshListenable.dispose();
  });
  return router;
});
