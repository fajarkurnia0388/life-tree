import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Circadian / celestial period used by theme tinting and dev simulation.
enum CelestialTime { auto, morning, noon, sunset, night }

/// Dev-only overrides for theme / tree age simulation.
///
/// In release builds these providers still exist (Riverpod needs stable types),
/// but mutators no-op when [kDebugMode] is false so production UI cannot
/// silently depend on debug play state.
final devTimeOfDayOverrideProvider = StateProvider<CelestialTime>(
  (ref) => CelestialTime.auto,
);

final devCumulativeDaysOverrideProvider = StateProvider<int?>((ref) => null);

class DevAgePlayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;

  DevAgePlayNotifier(this._ref) : super(false);

  void toggle() {
    if (!kDebugMode) return;
    if (state) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    if (!kDebugMode) return;
    state = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      final current = _ref.read(devCumulativeDaysOverrideProvider) ?? 0;
      if (current >= 100) {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state = 0;
      } else {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state =
            current + 1;
      }
    });
  }

  void stop() {
    state = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final devAgePlayProvider = StateNotifierProvider<DevAgePlayNotifier, bool>((
  ref,
) {
  final notifier = DevAgePlayNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class DevTimePlayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;

  DevTimePlayNotifier(this._ref) : super(false);

  void toggle() {
    if (!kDebugMode) return;
    if (state) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    if (!kDebugMode) return;
    state = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      final current = _ref.read(devTimeOfDayOverrideProvider);
      final next = switch (current) {
        CelestialTime.morning => CelestialTime.noon,
        CelestialTime.noon => CelestialTime.sunset,
        CelestialTime.sunset => CelestialTime.night,
        _ => CelestialTime.morning,
      };
      _ref.read(devTimeOfDayOverrideProvider.notifier).state = next;
    });
  }

  void stop() {
    state = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final devTimePlayProvider = StateNotifierProvider<DevTimePlayNotifier, bool>((
  ref,
) {
  final notifier = DevTimePlayNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
