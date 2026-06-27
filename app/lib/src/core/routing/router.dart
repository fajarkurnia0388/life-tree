import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/dashboard/dashboard_view.dart';
import '../../features/journal/journal_lite_view.dart';
import '../../features/thinking_canvas/thinking_canvas_lite_view.dart';
import '../../features/safety/safety_card_view.dart';
import '../../features/habit/add_habit_view.dart';
import '../../features/marketplace/marketplace_view.dart';
import '../../features/weekly_pulse/weekly_pulse_view.dart';
import '../../features/decision_journal/decision_journal_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If the onboarding status is still loading, wait
      final value = onboardingCompleted.valueOrNull;
      if (value == null) return null;

      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!value) {
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
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalLiteView(),
      ),
      GoRoute(
        path: '/thinking-canvas',
        builder: (context, state) => const ThinkingCanvasLiteView(),
      ),
      GoRoute(
        path: '/safety',
        builder: (context, state) => const SafetyCardView(),
      ),
      GoRoute(
        path: '/add-habit',
        builder: (context, state) => const AddHabitView(),
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
    ],
  );
});
