import 'cultivation_constants.dart';

/// 3-Level Language System for Daoji Cultivation Layer
///
/// Provides consistent terminology across Plain, Hybrid (default), and Full
/// cultivation modes. All UI strings should resolve through this class to
/// maintain language level consistency.
class CultivationStrings {
  const CultivationStrings._();

  // ============================================================================
  // DASHBOARD STRINGS
  // ============================================================================

  static String dashboardTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => '🌳 Pohonmu',
      CultivationLanguageLevel.hybrid => '☯️ Dao Tree',
      CultivationLanguageLevel.full => '☯️ Inner World Tree',
    };
  }

  static String realmDisplay(
    CultivationLanguageLevel level,
    String realmName,
    int days,
  ) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Hari ke-$days',
      CultivationLanguageLevel.hybrid => '$realmName — Hari $days',
      CultivationLanguageLevel.full => '九炼·$realmName — Hari $days',
    };
  }

  static String seasonRecovery(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Mode Istirahat',
      CultivationLanguageLevel.hybrid => 'Seclusion Aktif',
      CultivationLanguageLevel.full => 'Closed-Door Seclusion',
    };
  }

  static String seasonGrowth(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Mode Aktif',
      CultivationLanguageLevel.hybrid => 'Growth Phase',
      CultivationLanguageLevel.full => 'Cultivation Progress',
    };
  }

  static String seasonDormant(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Mode Istirahat Panjang',
      CultivationLanguageLevel.hybrid => 'Dormant Phase',
      CultivationLanguageLevel.full => 'Winter Hibernation',
    };
  }

  static String seasonTribulation(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Mode Tantangan',
      CultivationLanguageLevel.hybrid => 'Tribulation',
      CultivationLanguageLevel.full => 'Heavenly Tribulation',
    };
  }

  static String seasonQuietIntegration(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Pemulihan Tenang',
      CultivationLanguageLevel.hybrid => 'Quiet Integration',
      CultivationLanguageLevel.full => 'Silent Comprehension',
    };
  }

  // ============================================================================
  // ACTION OF THE DAY
  // ============================================================================

  static String actionOfTheDayTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => '📋 Prioritas Hari Ini',
      CultivationLanguageLevel.hybrid => '⚔️ Breakthrough Hari Ini',
      CultivationLanguageLevel.full => '🧘 One Practice',
    };
  }

  static String actionOfTheDaySubtitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Domain terlemah',
      CultivationLanguageLevel.hybrid => 'Palace butuh Qi',
      CultivationLanguageLevel.full => 'Meridian redup',
    };
  }

  static String actionCompleted(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => '✅ Selesai!',
      CultivationLanguageLevel.hybrid => '✅ Practice selesai, +Qi',
      CultivationLanguageLevel.full => '✅ Teknik dikuasai',
    };
  }

  // ============================================================================
  // HABIT / PRACTICE STRINGS
  // ============================================================================

  static String habitLabel(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kebiasaan',
      CultivationLanguageLevel.hybrid => 'Practice',
      CultivationLanguageLevel.full => 'Cultivation Technique',
    };
  }

  static String habitListTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kebiasaan Hari Ini',
      CultivationLanguageLevel.hybrid => 'Scheduled Practices',
      CultivationLanguageLevel.full => 'Daily Techniques',
    };
  }

  static String addHabit(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Tambah Kebiasaan',
      CultivationLanguageLevel.hybrid => 'Tambah Practice',
      CultivationLanguageLevel.full => 'Adopt Technique',
    };
  }

  // ============================================================================
  // FRICTION INTERVENTION
  // ============================================================================

  static String frictionInterventionTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Hambatan apa?',
      CultivationLanguageLevel.hybrid => 'Bottleneck apa?',
      CultivationLanguageLevel.full => 'Heart Demon macam apa?',
    };
  }

  static String frictionOptionTime(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kurang Waktu',
      CultivationLanguageLevel.hybrid => 'Qi belum terkumpul',
      CultivationLanguageLevel.full => 'Qi-mu bocor',
    };
  }

  static String frictionOptionEnergy(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kelelahan',
      CultivationLanguageLevel.hybrid => 'Energi habis',
      CultivationLanguageLevel.full => 'Shen-mu lelah',
    };
  }

  static String frictionOptionForgot(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Lupa',
      CultivationLanguageLevel.hybrid => 'Fokus buyar',
      CultivationLanguageLevel.full => 'Pikiranmu tercerai',
    };
  }

  // ============================================================================
  // JOURNAL STRINGS
  // ============================================================================

  static String journalTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => '📝 Catatan Harian',
      CultivationLanguageLevel.hybrid => '📝 Qi Log',
      CultivationLanguageLevel.full => '📜 Heart Scripture',
    };
  }

  static String journalLite(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Cepat',
      CultivationLanguageLevel.hybrid => 'Journal Ringan',
      CultivationLanguageLevel.full => 'Meditasi Cepat',
    };
  }

  static String journalDeep(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Refleksi',
      CultivationLanguageLevel.hybrid => 'Deep Reflection',
      CultivationLanguageLevel.full => 'Pemurnian Shen',
    };
  }

  static String journalMoodPrompt(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Bagaimana perasaanmu hari ini?',
      CultivationLanguageLevel.hybrid => 'Bagaimana aliran energimu hari ini?',
      CultivationLanguageLevel.full => 'Bagaimana keselarasan Qi-mu hari ini?',
    };
  }

  // ============================================================================
  // GROWTH MAP / TREE STRINGS
  // ============================================================================

  static String growthMapRoot(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Akar Diri',
      CultivationLanguageLevel.hybrid => 'Dao Heart',
      CultivationLanguageLevel.full => 'Dao Heart (道心)',
    };
  }

  static String growthMapBranch(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Domain',
      CultivationLanguageLevel.hybrid => 'Palace',
      CultivationLanguageLevel.full => 'Palace (殿)',
    };
  }

  static String growthMapLeaf(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kebiasaan',
      CultivationLanguageLevel.hybrid => 'Practice',
      CultivationLanguageLevel.full => 'Cultivation Technique',
    };
  }

  static String growthMapFlower(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Stabil',
      CultivationLanguageLevel.hybrid => 'Pattern Mengakar',
      CultivationLanguageLevel.full => 'Automaticity',
    };
  }

  static String growthMapFruit(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Keputusan',
      CultivationLanguageLevel.hybrid => 'Wisdom Fruit',
      CultivationLanguageLevel.full => 'Dao Fruit (道果)',
    };
  }

  // ============================================================================
  // CANOPY LOAD / QI CAPACITY
  // ============================================================================

  static String canopyLoadTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Beban Harian',
      CultivationLanguageLevel.hybrid => 'Daily Qi Capacity',
      CultivationLanguageLevel.full => 'Dantian Capacity',
    };
  }

  static String canopyLoadOverload(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Terlalu banyak target',
      CultivationLanguageLevel.hybrid => 'Qi overload',
      CultivationLanguageLevel.full => 'Meridian tersumbat',
    };
  }

  // ============================================================================
  // WEEKLY PULSE / REFLECTION
  // ============================================================================

  static String weeklyPulseTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Review Mingguan',
      CultivationLanguageLevel.hybrid => 'Meridian Check',
      CultivationLanguageLevel.full => 'Resonance Check',
    };
  }

  // ============================================================================
  // LIFE COMPASS / DAO HEART
  // ============================================================================

  static String lifeCompassTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Kompas Hidup',
      CultivationLanguageLevel.hybrid => 'Dao Heart',
      CultivationLanguageLevel.full => 'Dao Heart (道心)',
    };
  }

  static String valueMirrorTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Cermin Nilai',
      CultivationLanguageLevel.hybrid => 'Dao Heart Mirror',
      CultivationLanguageLevel.full => 'Heart Demon Mirror',
    };
  }

  // ============================================================================
  // DECISION JOURNAL
  // ============================================================================

  static String decisionJournalTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Catatan Keputusan',
      CultivationLanguageLevel.hybrid => 'Forked Path Journal',
      CultivationLanguageLevel.full => 'Dao Crossroads Record',
    };
  }

  // ============================================================================
  // MARKETPLACE
  // ============================================================================

  static String marketplaceTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Template Komunitas',
      CultivationLanguageLevel.hybrid => 'Sutra Pavilion',
      CultivationLanguageLevel.full => 'Heritage Archive',
    };
  }

  // ============================================================================
  // RECOVERY MODE
  // ============================================================================

  static String recoveryModeTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Mode Istirahat',
      CultivationLanguageLevel.hybrid => 'Seclusion Mode',
      CultivationLanguageLevel.full => 'Closed-Door Cultivation',
    };
  }

  static String recoveryModeDescription(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain =>
        'Semua kebiasaan dipause. Fokus pemulihan.',
      CultivationLanguageLevel.hybrid => 'Practices paused. Focus on recovery.',
      CultivationLanguageLevel.full =>
        'Techniques suspended. Inner healing prioritized.',
    };
  }

  // ============================================================================
  // SAFETY CARD (Always clear, dual label when needed)
  // ============================================================================

  static String safetyCardTitle(CultivationLanguageLevel level) {
    // Safety Card always uses plain language
    return 'Kartu Keselamatan / Safety Card';
  }

  // ============================================================================
  // SETTINGS
  // ============================================================================

  static String settingsLanguageLevelTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Bahasa',
      CultivationLanguageLevel.hybrid => 'Gaya Bahasa',
      CultivationLanguageLevel.full => 'Language Level',
    };
  }

  static String languageLevelPlain(CultivationLanguageLevel level) {
    return 'Sehari-hari';
  }

  static String languageLevelHybrid(CultivationLanguageLevel level) {
    return 'Paduan Tenang';
  }

  static String languageLevelFull(CultivationLanguageLevel level) {
    return 'Nuansa Kultivasi';
  }

  // ============================================================================
  // PALACE NAMES (Domain Mapping)
  // ============================================================================

  static String palaceName(
    CultivationPalace palace,
    CultivationLanguageLevel level,
  ) {
    return switch (palace) {
      CultivationPalace.body => switch (level) {
        CultivationLanguageLevel.plain => 'Tubuh',
        CultivationLanguageLevel.hybrid => 'Body Palace',
        CultivationLanguageLevel.full => 'Body Palace (体殿)',
      },
      CultivationPalace.resource => switch (level) {
        CultivationLanguageLevel.plain => 'Keuangan',
        CultivationLanguageLevel.hybrid => 'Resource Palace',
        CultivationLanguageLevel.full => 'Resource Palace (财殿)',
      },
      CultivationPalace.bond => switch (level) {
        CultivationLanguageLevel.plain => 'Hubungan',
        CultivationLanguageLevel.hybrid => 'Bond Palace',
        CultivationLanguageLevel.full => 'Bond Palace (缘殿)',
      },
      CultivationPalace.heartSea => switch (level) {
        CultivationLanguageLevel.plain => 'Emosi',
        CultivationLanguageLevel.hybrid => 'Heart Sea',
        CultivationLanguageLevel.full => 'Heart Sea (心海)',
      },
      CultivationPalace.craft => switch (level) {
        CultivationLanguageLevel.plain => 'Karir',
        CultivationLanguageLevel.hybrid => 'Craft Palace',
        CultivationLanguageLevel.full => 'Craft Palace (技殿)',
      },
      CultivationPalace.joy => switch (level) {
        CultivationLanguageLevel.plain => 'Rekreasi',
        CultivationLanguageLevel.hybrid => 'Joy Garden',
        CultivationLanguageLevel.full => 'Joy Garden (乐园)',
      },
    };
  }

  // ============================================================================
  // RADAR CHART / PALACE RESONANCE
  // ============================================================================

  static String radarChartTitle(CultivationLanguageLevel level) {
    return switch (level) {
      CultivationLanguageLevel.plain => 'Keseimbangan Hidup',
      CultivationLanguageLevel.hybrid => 'Six Palace Resonance',
      CultivationLanguageLevel.full => 'Palace Harmony Chart',
    };
  }
}
