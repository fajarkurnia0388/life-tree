import '../../data/local_db/database.dart';

/// Stateless helper for computing habit priority scores.
/// Applies input clamping (B = MAP model by BJ Fogg) to prevent
/// division-by-zero and guarantee safe range for all parameters.
class PriorityHelper {
  /// Calculates the Action of the Day priority score.
  /// Formula: (domainDeficit × impactScore) / (initiationFriction + energyCost)
  /// All parameters are clamped to valid ranges before calculation.
  static double calculatePriority({
    required double palaceDeficit,      // Expected: 0.0–10.0
    required double impactScore,        // Expected: 1.0–5.0
    required double initiationFriction, // Expected: 1.0–5.0
    required double energyCost,         // Expected: 1.0–5.0
  }) {
    final safeDeficit  = palaceDeficit.clamp(0.0, 10.0);
    final safeImpact   = impactScore.clamp(1.0, 5.0);
    final safeFriction = initiationFriction.clamp(1.0, 5.0);
    final safeEnergy   = energyCost.clamp(1.0, 5.0);
    // Lower denominator → higher priority (B = MAP: lower friction = higher ability)
    return (safeDeficit * safeImpact) / (safeFriction + safeEnergy);
  }
}

/// Computes the Action of the Day priority score for a single [Habit].
/// Higher score = higher priority.
/// Delegates to [PriorityHelper.calculatePriority] for safe, clamped calculation.
double computeHabitPriorityScore({
  required Habit habit,
  required Map<String, dynamic> domainScores,
}) {
  final domain = habit.domainTag ?? 'Tubuh';
  final rawScore = domainScores[domain] ?? 5;
  final domainScore = (rawScore is num) ? rawScore.toDouble() : 5.0;
  final domainDeficit = 10.0 - domainScore;

  return PriorityHelper.calculatePriority(
    palaceDeficit: domainDeficit,
    impactScore: habit.impactScore.toDouble(),
    initiationFriction: habit.initiationFriction.toDouble(),
    energyCost: habit.energyCost.toDouble(),
  );
}
