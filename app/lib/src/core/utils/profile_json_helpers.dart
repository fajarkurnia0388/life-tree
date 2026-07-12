import '../../data/local_db/database.dart';
import '../domain/app_constants.dart';

extension UserProfileJsonParsing on UserProfile {
  /// Safely parses latestDomainScores and returns `Map<String, double>`.
  /// Falls back to DomainDefaults.scores when missing or unparseable.
  Map<String, double> get parsedDomainScores {
    final scores = Map<String, double>.from(DomainDefaults.scores);
    final current = latestDomainScores;
    if (current == null) return scores;
    current.forEach((key, value) {
      if (scores.containsKey(key)) {
        scores[key] = value;
      }
    });
    return scores;
  }

  /// Safely parses coreValues and returns `List<String>`.
  /// Returns empty list when missing or unparseable.
  List<String> get parsedCoreValues {
    return coreValues ?? const [];
  }

  /// Safely parses revealedValueScores and returns `Map<String, int>`.
  /// Returns empty map when missing or unparseable.
  Map<String, int> get parsedRevealedValueScores {
    return revealedValueScores ?? const {};
  }
}
