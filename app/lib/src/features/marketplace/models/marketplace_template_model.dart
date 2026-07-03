import 'dart:convert';

/// Base marketplace template that supports multiple template types
class MarketplaceTemplateModel {
  final String templateId;
  final String templateType; // 'habit' or 'core_value'
  final String title;
  final String description;
  final String? domainTag;
  final TemplateMetadata? metadata;
  final String creatorPenName;
  final int ratingsSum;
  final int ratingsCount;
  final int downloadsCount;
  final DateTime createdAt;

  MarketplaceTemplateModel({
    required this.templateId,
    required this.templateType,
    required this.title,
    required this.description,
    this.domainTag,
    this.metadata,
    required String? creatorPenName,
    required this.ratingsSum,
    required this.ratingsCount,
    required this.downloadsCount,
    required this.createdAt,
  }) : creatorPenName = creatorPenName ?? 'Anonim';

  double get averageRating =>
      ratingsCount == 0 ? 0.0 : ratingsSum / ratingsCount;

  bool get isHabit => templateType == 'habit';
  bool get isCoreValue => templateType == 'core_value';

  HabitTemplateMetadata? get habitMetadata => metadata is HabitTemplateMetadata
      ? metadata as HabitTemplateMetadata
      : null;

  CoreValueTemplateMetadata? get coreValueMetadata =>
      metadata is CoreValueTemplateMetadata
      ? metadata as CoreValueTemplateMetadata
      : null;
}

/// Base class for template-specific metadata
abstract class TemplateMetadata {
  Map<String, dynamic> toJson();

  static TemplateMetadata? fromJson(String templateType, String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      switch (templateType) {
        case 'habit':
          return HabitTemplateMetadata.fromJson(json);
        case 'core_value':
          return CoreValueTemplateMetadata.fromJson(json);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }
}

/// Habit-specific template metadata
class HabitTemplateMetadata extends TemplateMetadata {
  final int friction;
  final int energy;
  final int impact;
  final int mvaDuration;

  HabitTemplateMetadata({
    required this.friction,
    required this.energy,
    required this.impact,
    required this.mvaDuration,
  });

  factory HabitTemplateMetadata.fromJson(Map<String, dynamic> json) {
    return HabitTemplateMetadata(
      friction: json['friction'] as int? ?? 3,
      energy: json['energy'] as int? ?? 3,
      impact: json['impact'] as int? ?? 3,
      mvaDuration: json['mvaDuration'] as int? ?? 2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'friction': friction,
      'energy': energy,
      'impact': impact,
      'mvaDuration': mvaDuration,
    };
  }
}

/// Core Value template metadata
class CoreValueTemplateMetadata extends TemplateMetadata {
  final String emoji;
  final String whyItMatters;
  final List<String> relatedDomains;
  final String reflectionPrompt;

  CoreValueTemplateMetadata({
    required this.emoji,
    required this.whyItMatters,
    required this.relatedDomains,
    required this.reflectionPrompt,
  });

  factory CoreValueTemplateMetadata.fromJson(Map<String, dynamic> json) {
    return CoreValueTemplateMetadata(
      emoji: json['emoji'] as String? ?? '⭐',
      whyItMatters: json['whyItMatters'] as String? ?? '',
      relatedDomains:
          (json['relatedDomains'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reflectionPrompt: json['reflectionPrompt'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'whyItMatters': whyItMatters,
      'relatedDomains': relatedDomains,
      'reflectionPrompt': reflectionPrompt,
    };
  }
}
