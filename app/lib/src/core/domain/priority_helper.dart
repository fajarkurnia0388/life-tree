import '../../data/local_db/database.dart';

/// Computes the Action of the Day priority score for a single habit.
/// Higher score = higher priority.
/// Formula: (domain_deficit × impact_score) / (initiation_friction + energy_cost)
double computeHabitPriorityScore({
  required Habit habit,
  required Map<String, dynamic> domainScores,
}) {
  final domain = habit.domainTag ?? 'Tubuh';
  final rawScore = domainScores[domain] ?? 5;
  final domainScore = (rawScore is num) ? rawScore.toDouble() : 5.0;
  final domainDeficit = 10.0 - domainScore;
  final totalLoad = habit.initiationFriction + habit.energyCost;
  return (domainDeficit * habit.impactScore) / (totalLoad > 0 ? totalLoad : 1);
}
