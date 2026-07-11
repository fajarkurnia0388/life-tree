import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/local_db/database.dart';
import '../domain/app_constants.dart';

extension UserProfileJsonParsing on UserProfile {
  /// Safely parses latestDomainScores and returns Map<String, double>.
  /// Falls back to DomainDefaults.scores when missing or unparseable.
  Map<String, double> get parsedDomainScores {
    final scores = Map<String, double>.from(DomainDefaults.scores);
    final raw = latestDomainScores;
    if (raw == null || raw.trim().isEmpty) return scores;
    try {
      final Map<String, dynamic> parsed = jsonDecode(raw);
      parsed.forEach((key, value) {
        final numVal = value as num;
        if (scores.containsKey(key)) {
          scores[key] = numVal.toDouble();
        }
      });
    } catch (e) {
      debugPrint('[UserProfileJsonParsing] Error parsing domain scores: $e');
    }
    return scores;
  }

  /// Safely parses coreValues and returns List<String>.
  /// Returns empty list when missing or unparseable.
  List<String> get parsedCoreValues {
    final raw = coreValues;
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final List<dynamic> parsed = jsonDecode(raw);
      return parsed.map((v) => v.toString()).toList();
    } catch (e) {
      debugPrint('[UserProfileJsonParsing] Error parsing core values: $e');
      return const [];
    }
  }

  /// Safely parses revealedValueScores and returns Map<String, int>.
  /// Returns empty map when missing or unparseable.
  Map<String, int> get parsedRevealedValueScores {
    final raw = revealedValueScores;
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final Map<String, dynamic> parsed = jsonDecode(raw);
      return parsed.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (e) {
      debugPrint('[UserProfileJsonParsing] Error parsing revealed value scores: $e');
      return const {};
    }
  }
}
