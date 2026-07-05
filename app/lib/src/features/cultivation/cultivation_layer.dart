import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'cultivation_constants.dart';

// Small wrapper that exposes a Map-like interface while allowing callers to
// lookup values using either `CultivationPath` or the legacy `CultivationPalace`.
class _DualPalaceMap implements Map<Object, double> {
  final Map<CultivationPath, double> _inner;
  _DualPalaceMap(this._inner);

  @override
  double? operator [](Object? key) {
    if (key is CultivationPath) return _inner[key];
    if (key is CultivationPalace) {
      final path = CultivationPath.values[key.index];
      return _inner[path];
    }
    return _inner[key];
  }

  @override
  Iterable<MapEntry<Object, double>> get entries =>
      _inner.entries.map((e) => MapEntry(e.key, e.value));

  @override
  Iterable<Object> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  Iterable<double> get values => _inner.values;

  // The rest of Map methods delegate to the inner map where meaningful.
  @override
  bool containsKey(Object? key) {
    if (key is CultivationPath) return _inner.containsKey(key);
    if (key is CultivationPalace) {
      return _inner.containsKey(CultivationPath.values[key.index]);
    }
    return _inner.containsKey(key);
  }

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  void forEach(void Function(Object key, double value) action) =>
      _inner.forEach(action);

  // Unsupported mutation operations for this read-only wrapper.
  @override
  double putIfAbsent(Object key, double Function() ifAbsent) =>
      throw UnimplementedError();
  @override
  void addAll(Map other) => throw UnimplementedError();
  @override
  double? remove(Object? key) => throw UnimplementedError();
  @override
  void clear() => throw UnimplementedError();
  @override
  void operator []=(Object key, double value) => throw UnimplementedError();

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(Object key, double value) transform,
  ) => _inner.map(
    (k, v) => MapEntry(transform(k, v).key as K2, transform(k, v).value as V2),
  );

  @override
  void addEntries(Iterable<MapEntry<Object, double>> newEntries) =>
      throw UnimplementedError();

  @override
  double update(
    Object key,
    double Function(double value) update, {
    double Function()? ifAbsent,
  }) => throw UnimplementedError();

  @override
  void updateAll(double Function(Object key, double value) update) =>
      throw UnimplementedError();

  @override
  void removeWhere(bool Function(Object key, double value) predicate) =>
      throw UnimplementedError();
}

/// Core cultivation layer that interprets existing dashboard data through
/// the lens of the 九炼归道 (Jiǔ Liàn Guī Dào) cultivation system.
///
/// This is an interpretive layer only — no database migration required.
/// All cultivation concepts map to existing data structures.
@immutable
class CultivationLayer {
  const CultivationLayer({
    required this.realm,
    required this.realmName,
    required this.season,
    required this.palaceScores,
    this.dominantPath,
    required this.qiLevel,
    required this.cumulativeDays,
    this.daoHeart,
    this.heartDemon,
  });

  /// Current realm (1-8) based on multi-signal calculation
  final int realm;

  /// Human-readable realm name (e.g., "Foundation Establishment")
  final String realmName;

  /// Current cultivation season/state
  final CultivationSeason season;

  /// Palace scores (0.0 - 10.0) mapped from domain scores
  /// Keys: body, resource, bond, heartSea, craft, joy
  /// Exposed as a Map that accepts lookup by either `CultivationPath`
  /// or legacy `CultivationPalace` for backward compatibility in tests.
  final Map<Object, double> palaceScores;

  /// Dominant cultivation path (optional, can be null in early stages)
  final CultivationPracticePath? dominantPath;

  /// Current Qi level (0.0 - 1.0) representing daily capacity usage
  final double qiLevel;

  /// Total cumulative practice days
  final int cumulativeDays;

  /// Core values / Dao Heart declaration
  final String? daoHeart;

  /// Detected heart demon (optional)
  final String? heartDemon;

  /// Factory constructor that builds cultivation layer from existing dashboard data.
  /// This is the primary integration point — no database changes needed.
  factory CultivationLayer.fromDashboard(DashboardData data) {
    // 1. Calculate Realm from multi-signal
    final realm = _calculateRealm(
      cumulativeDays: data.cumulativeDays,
      habitsToday: data.habitsToday,
      profile: data.profile,
    );

    final realmInfo = CultivationConstants.realmForLevel(realm);

    // 2. Determine Season/State
    final season = _determineSeason(data);

    // 3. Map domain scores to palace scores
    final palaceScores = _DualPalaceMap(
      _mapDomainsToPalaces(data.profile.latestDomainScores),
    );

    // 4. Calculate Qi level from canopy load
    final qiLevel = _calculateQiLevel(data.habitsToday, data.profile);

    // 5. Detect dominant path (optional, based on usage patterns)
    final dominantPath = _detectDominantPath(data);

    // 6. Extract Dao Heart from core values
    final daoHeart = data.profile.coreValues;

    // 7. Detect heart demon (optional)
    final heartDemon = _detectHeartDemon(data);

    return CultivationLayer(
      realm: realm,
      realmName: realmInfo.name,
      season: season,
      palaceScores: palaceScores,
      dominantPath: dominantPath,
      qiLevel: qiLevel,
      cumulativeDays: data.cumulativeDays,
      daoHeart: daoHeart,
      heartDemon: heartDemon,
    );
  }

  /// Multi-signal realm calculation (Task 0.2)
  ///
  /// Signals:
  /// - Cumulative days (40%)
  /// - Consistency (25%)
  /// - Reflection depth (20%)
  /// - Values clarity (15%)
  static int _calculateRealm({
    required int cumulativeDays,
    required List<HabitWithLog> habitsToday,
    required UserProfile profile,
  }) {
    double signal = 0.0;

    // Signal 1: Cumulative days (bobot 40%)
    // Max at 730 days (2 years) → realm 8
    final daysSignal =
        (cumulativeDays / CultivationConstants.maxRealmSignalDays).clamp(
          0.0,
          1.0,
        );
    signal += daysSignal * 0.4;

    // Signal 2: Consistency (bobot 25%)
    // Average completionRate90d from active habits
    double consistencySignal = 0.0;
    final habitsWithRate = habitsToday
        .where((hwl) => hwl.habit.completionRate90d != null)
        .toList();
    if (habitsWithRate.isNotEmpty) {
      final avgRate =
          habitsWithRate
              .map((hwl) => hwl.habit.completionRate90d!)
              .reduce((a, b) => a + b) /
          habitsWithRate.length;
      consistencySignal = avgRate.clamp(0.0, 1.0);
    }
    signal += consistencySignal * 0.25;

    // Signal 3: Reflection depth (bobot 20%)
    // Placeholder — would check JournalEntries and ThinkingCanvasSessions count
    // For now, use a basic heuristic: if recoveryEndDate exists, +0.5
    double reflectionSignal = 0.0;
    if (profile.recoveryEndDate != null) {
      reflectionSignal = 0.5; // Has gone through recovery = deeper reflection
    }
    signal += reflectionSignal * 0.2;

    // Signal 4: Values clarity (bobot 15%)
    // Check if coreValues is set and non-empty
    double valuesSignal = 0.0;
    if (profile.coreValues != null && profile.coreValues!.isNotEmpty) {
      valuesSignal = 0.8; // Has declared values
    }
    if (profile.revealedValueScores != null &&
        profile.revealedValueScores!.isNotEmpty) {
      valuesSignal = 1.0; // Has both declared and revealed values
    }
    signal += valuesSignal * 0.15;

    // Map signal (0.0 - 1.0) to realm (1 - 8)
    return _mapSignalToRealm(signal);
  }

  static int _mapSignalToRealm(double signal) {
    // Progressive thresholds — earlier realms easier to reach
    if (signal < 0.05) return 1; // Body Tempering
    if (signal < 0.15) return 2; // Qi Gathering
    if (signal < 0.30) return 3; // Foundation Establishment
    if (signal < 0.50) return 4; // Core Formation
    if (signal < 0.70) return 5; // Nascent Soul
    if (signal < 0.85) return 6; // Spirit Transformation
    if (signal < 0.95) return 7; // Dao Comprehension
    return 8; // World Bearing
  }

  /// Determine cultivation season from dashboard data (Task 0.3)
  static CultivationSeason _determineSeason(DashboardData data) {
    // Priority order:
    // 1. Recovery mode → recovery
    // 2. Dormant season → dormant
    // 3. Check for tribulation signals
    // 4. Default → growth

    if (data.season == 'Recovery') {
      return CultivationSeason.recovery;
    }

    if (data.season == 'Dormant') {
      return CultivationSeason.dormant;
    }

    // Tribulation detection: multiple missed habits + low mood indicators
    // For now, simplified: if many habits missed today
    final missedCount = data.habitsToday
        .where(
          (hwl) =>
              hwl.log != null &&
              (hwl.log!.status == 'Missed' ||
                  hwl.log!.frictionReasonSelected != null),
        )
        .length;

    if (missedCount >= 3) {
      return CultivationSeason.tribulation;
    }

    // Quiet Integration: just exited recovery
    if (data.profile.recoveryEndDate != null) {
      final daysSinceRecovery = DateTime.now()
          .difference(data.profile.recoveryEndDate!)
          .inDays;
      if (daysSinceRecovery >= 0 && daysSinceRecovery <= 7) {
        return CultivationSeason.quietIntegration;
      }
    }

    // Default: growth
    return CultivationSeason.growth;
  }

  /// Map domain scores (JSON string) to palace scores
  static Map<CultivationPath, double> _mapDomainsToPalaces(
    String? domainScoresJson,
  ) {
    final Map<CultivationPath, double> result = {
      CultivationPath.body: 5.0,
      CultivationPath.resource: 5.0,
      CultivationPath.bond: 5.0,
      CultivationPath.heartSea: 5.0,
      CultivationPath.craft: 5.0,
      CultivationPath.joy: 5.0,
    };

    if (domainScoresJson == null || domainScoresJson.isEmpty) {
      return result;
    }

    try {
      final Map<String, dynamic> domainScores = jsonDecode(domainScoresJson);

      // Map domain keys to palaces
      final mapping = {
        'Tubuh': CultivationPath.body,
        'Keuangan': CultivationPath.resource,
        'Hubungan': CultivationPath.bond,
        'Emosi': CultivationPath.heartSea,
        'Karir': CultivationPath.craft,
        'Rekreasi': CultivationPath.joy,
      };

      for (final entry in mapping.entries) {
        final domainKey = entry.key;
        final palace = entry.value;
        if (domainScores.containsKey(domainKey)) {
          final score = domainScores[domainKey];
          if (score is num) {
            result[palace] = score.toDouble().clamp(0.0, 10.0);
          }
        }
      }
    } catch (e) {
      // If parsing fails, return defaults
      debugPrint('CultivationLayer: Failed to parse domainScores: $e');
    }

    return result;
  }

  /// Calculate Qi level from canopy load
  static double _calculateQiLevel(
    List<HabitWithLog> habitsToday,
    UserProfile profile,
  ) {
    // Qi level = 1.0 - (canopyLoad / capacity)
    // Higher load = lower Qi available

    double totalLoad = 0.0;
    for (final hwl in habitsToday) {
      final friction = hwl.habit.initiationFriction;
      final energy = hwl.habit.energyCost;
      totalLoad += (friction + energy).toDouble();
    }

    final capacity = profile.canopyLoadCapacity.toDouble();
    final loadRatio = (totalLoad / capacity).clamp(0.0, 2.0);

    // Invert: high load = low Qi
    final qiLevel = (1.0 - (loadRatio * 0.5)).clamp(0.0, 1.0);

    return qiLevel;
  }

  /// Detect dominant cultivation path from usage patterns (Phase 3 feature)
  static CultivationPracticePath? _detectDominantPath(DashboardData data) {
    // Placeholder for Phase 3
    // Would analyze:
    // - Journal entry frequency → Word Path
    // - Decision journal usage → Sword Path
    // - Habit scheduling patterns → Formation Path
    // - Physical domain focus → Body Path
    // - Reflection depth → Alchemist Path
    // - Recovery mode usage → Shadow Path

    return null; // Not implemented in Phase 0
  }

  /// Detect heart demon from behavior patterns (Phase 3 feature)
  static String? _detectHeartDemon(DashboardData data) {
    // Placeholder for Phase 3
    // Would detect patterns like:
    // - Perfection demon: missed → immediate mood drop
    // - Impatience demon: frequent habit changes
    // - Attachment demon: habits never archived

    return null; // Not implemented in Phase 0
  }

  /// Get lowest palace score (for Action of the Day targeting)
  CultivationPalace getLowestPalace() {
    final entry = palaceScores.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );
    // entry.key may be a CultivationPath; normalize to CultivationPath then map
    CultivationPath path;
    if (entry.key is CultivationPath) {
      path = entry.key as CultivationPath;
    } else if (entry.key is CultivationPalace) {
      path = CultivationPath.values[(entry.key as CultivationPalace).index];
    } else {
      // Fallback: default to body
      path = CultivationPath.body;
    }
    return CultivationPalace.values[path.index];
  }

  /// Check if in overload state
  bool get isOverloaded => qiLevel < 0.3;

  /// Check if in balanced state
  bool get isBalanced {
    final scores = palaceScores.values.toList();
    final max = scores.reduce((a, b) => a > b ? a : b);
    final min = scores.reduce((a, b) => a < b ? a : b);
    return (max - min) <= 3.0; // Variance threshold
  }

  @override
  String toString() {
    return 'CultivationLayer(realm: $realm/$realmName, season: $season, '
        'qi: ${(qiLevel * 100).toStringAsFixed(0)}%, days: $cumulativeDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CultivationLayer &&
        other.realm == realm &&
        other.season == season &&
        other.cumulativeDays == cumulativeDays;
  }

  @override
  int get hashCode => Object.hash(realm, season, cumulativeDays);
}
