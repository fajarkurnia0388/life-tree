/// Service for computing dynamic Canopy Load capacity based on WHO-5 well-being
/// scores, implementing the Calm Technology principle of adaptive energy limits.
///
/// Formula: C_adj = C_base × (0.3 + 0.7 × W_score)
/// where W_score = (WHO-5 percentage / 100), normalised to [0.0, 1.0].
///
/// This ensures:
///   - Even when W_score = 0 (severe distress), minimum capacity = 30% of base.
///   - When W_score = 1 (flourishing), full base capacity is available.
class CanopyLoadService {
  /// Computes an adjusted canopy load capacity from the WHO-5 well-being score.
  ///
  /// [who5Percentage] - the raw WHO-5 percentage score (0–100).
  /// [baseCapacity]   - the user's baseline canopy load capacity from their profile.
  ///
  /// Returns the adjusted capacity (always ≥ 30 % of [baseCapacity]).
  static int calculateDynamicCapacity({
    required int who5Percentage,
    required int baseCapacity,
  }) {
    // Normalise to [0.0, 1.0]
    final wScore = (who5Percentage / 100.0).clamp(0.0, 1.0);
    // Floor at 30 % so the system never fully disables itself
    final adjusted = baseCapacity * (0.3 + 0.7 * wScore);
    return adjusted.round().clamp(1, baseCapacity);
  }

  /// Returns true when [who5Percentage] falls below the clinical well-being
  /// threshold (< 50 %), indicating Recovery Mode should be active.
  static bool isLowWellBeing(int who5Percentage) => who5Percentage < 50;

  /// Returns true when adding [additionalLoad] on top of [currentLoad] would
  /// exceed the [dynamicCapacity] ceiling.
  static bool isOverloaded({
    required int currentLoad,
    required int additionalLoad,
    required int dynamicCapacity,
  }) =>
      (currentLoad + additionalLoad) > dynamicCapacity;
}
