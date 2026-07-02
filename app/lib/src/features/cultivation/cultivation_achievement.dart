import 'cultivation_constants.dart';

/// Achievement definition for the cultivation layer.
///
/// Phase 0 only defines the model. Detection/unlock logic is planned for Phase 3.
class CultivationAchievement {
  const CultivationAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.trigger,
    required this.minimumLanguageLevel,
  });

  final String id;
  final String title;
  final String description;
  final String trigger;
  final CultivationLanguageLevel minimumLanguageLevel;
}

class CultivationAchievements {
  const CultivationAchievements._();

  static const initial = <CultivationAchievement>[
    CultivationAchievement(
      id: 'realm_breakthrough',
      title: 'Realm Breakthrough',
      description: 'Dao Heart-mu semakin kokoh.',
      trigger: 'Pertama kali masuk realm baru',
      minimumLanguageLevel: CultivationLanguageLevel.hybrid,
    ),
    CultivationAchievement(
      id: 'qi_milestone_100',
      title: 'Qi Milestone',
      description: 'Qi-mu mulai terkumpul — 100 practice.',
      trigger: '100 practice selesai',
      minimumLanguageLevel: CultivationLanguageLevel.hybrid,
    ),
    CultivationAchievement(
      id: 'tribulation_survivor',
      title: 'Tribulation Survivor',
      description: 'Kamu melewati tribulation dan bangkit lebih kuat.',
      trigger: 'Pertama kali selesai Recovery',
      minimumLanguageLevel: CultivationLanguageLevel.hybrid,
    ),
    CultivationAchievement(
      id: 'dao_comprehension_year',
      title: 'Dao Comprehension',
      description: 'Setahun dalam Dao — bijaksana dalam setiap langkah.',
      trigger: '1 tahun berkultivasi',
      minimumLanguageLevel: CultivationLanguageLevel.hybrid,
    ),
    CultivationAchievement(
      id: 'legacy_builder',
      title: 'Legacy Builder',
      description: 'Warisan teknikmu membantu kultivator lain.',
      trigger: 'Bagikan template di Marketplace',
      minimumLanguageLevel: CultivationLanguageLevel.hybrid,
    ),
  ];
}
