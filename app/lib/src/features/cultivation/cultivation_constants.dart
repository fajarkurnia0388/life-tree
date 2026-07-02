/// Core constants and enumerations for Daoji's cultivation layer.
///
/// This file intentionally contains no database dependencies. The cultivation
/// system is an interpretive layer over existing habit, reflection, and profile
/// data.
enum CultivationSeason {
  growth,
  recovery,
  dormant,
  tribulation,
  quietIntegration,
}

enum CultivationPath {
  sword,
  alchemist,
  formation,
  body,
  word,
  shadow,
}

enum CultivationLanguageLevel {
  plain,
  hybrid,
  full,
}

enum CultivationPalace {
  body,
  resource,
  bond,
  heartSea,
  craft,
  joy,
}

class CultivationRealm {
  const CultivationRealm({
    required this.level,
    required this.name,
    required this.chineseName,
    required this.indonesianName,
    required this.focus,
    required this.mindset,
  });

  final int level;
  final String name;
  final String chineseName;
  final String indonesianName;
  final String focus;
  final String mindset;
}

class CultivationPalaceInfo {
  const CultivationPalaceInfo({
    required this.palace,
    required this.name,
    required this.domainKey,
    required this.element,
    required this.primaryPractice,
  });

  final CultivationPalace palace;
  final String name;
  final String domainKey;
  final String element;
  final String primaryPractice;
}

class CultivationPathInfo {
  const CultivationPathInfo({
    required this.path,
    required this.name,
    required this.core,
    required this.strength,
    required this.shadowRisk,
  });

  final CultivationPath path;
  final String name;
  final String core;
  final String strength;
  final String shadowRisk;
}

class CultivationConstants {
  const CultivationConstants._();

  static const defaultQiCapacity = 10.0;
  static const maxRealmSignalDays = 730.0;

  static const realms = <CultivationRealm>[
    CultivationRealm(
      level: 1,
      name: 'Body Tempering',
      chineseName: '炼体',
      indonesianName: 'Penempaan Raga',
      focus: 'Tidur, nutrisi, gerak, napas, ritme sirkadian',
      mindset: 'Tubuhku adalah bejana pertama perjalananku.',
    ),
    CultivationRealm(
      level: 2,
      name: 'Qi Gathering',
      chineseName: '聚气',
      indonesianName: 'Pengumpulan Qi',
      focus: 'Fokus, pengelolaan distraksi, satu aksi kecil yang dituntaskan',
      mindset: 'Masalahku bukan kurang niat — qi-ku tercerai-berai.',
    ),
    CultivationRealm(
      level: 3,
      name: 'Foundation Establishment',
      chineseName: '筑基',
      indonesianName: 'Pendirian Fondasi',
      focus: 'Kebiasaan stabil dan sistem hidup yang bisa diandalkan',
      mindset: 'Perubahan tidak lagi bergantung pada semangat sesaat.',
    ),
    CultivationRealm(
      level: 4,
      name: 'Core Formation',
      chineseName: '结丹',
      indonesianName: 'Pembentukan Inti',
      focus: 'Nilai inti, prioritas hidup, batas sehat, keputusan selaras',
      mindset: 'Aku tidak lagi hidup dari validasi eksternal.',
    ),
    CultivationRealm(
      level: 5,
      name: 'Nascent Soul',
      chineseName: '元婴',
      indonesianName: 'Kelahiran Jiwa Pengamat',
      focus: 'Metakognisi, kesadaran emosi, jeda sebelum reaksi',
      mindset: 'Diri tidak lagi sepenuhnya tenggelam di dalam pikirannya.',
    ),
    CultivationRealm(
      level: 6,
      name: 'Spirit Transformation',
      chineseName: '化神',
      indonesianName: 'Transformasi Spirit',
      focus: 'Integrasi luka, respons matang, ketenangan tanpa mati rasa',
      mindset: 'Luka tidak hilang, tapi tidak lagi menjadi pusat identitas.',
    ),
    CultivationRealm(
      level: 7,
      name: 'Dao Comprehension',
      chineseName: '悟道',
      indonesianName: 'Pemahaman Dao',
      focus: 'Sebab-akibat, ritme, leverage, dan pola hidup',
      mindset: 'Aku tidak lagi sekadar berusaha keras — aku mulai melihat pola.',
    ),
    CultivationRealm(
      level: 8,
      name: 'World Bearing',
      chineseName: '合道载世',
      indonesianName: 'Menyangga Dunia',
      focus: 'Kontribusi, bimbingan, sistem yang menopang orang lain',
      mindset: 'Hidup tidak lagi berputar di sekitar aku.',
    ),
  ];

  static const palaces = <CultivationPalaceInfo>[
    CultivationPalaceInfo(
      palace: CultivationPalace.body,
      name: 'Body Palace',
      domainKey: 'Tubuh',
      element: 'Tanah',
      primaryPractice: 'Tidur, olahraga, napas, hidrasi',
    ),
    CultivationPalaceInfo(
      palace: CultivationPalace.resource,
      name: 'Resource Palace',
      domainKey: 'Keuangan',
      element: 'Logam',
      primaryPractice: 'Catat pengeluaran, budget, dana darurat',
    ),
    CultivationPalaceInfo(
      palace: CultivationPalace.bond,
      name: 'Bond Palace',
      domainKey: 'Hubungan',
      element: 'Api',
      primaryPractice: 'Koneksi, quality time, perbaikan konflik',
    ),
    CultivationPalaceInfo(
      palace: CultivationPalace.heartSea,
      name: 'Heart Sea',
      domainKey: 'Emosi',
      element: 'Air',
      primaryPractice: 'Journaling, meditasi, grounding',
    ),
    CultivationPalaceInfo(
      palace: CultivationPalace.craft,
      name: 'Craft Palace',
      domainKey: 'Karir',
      element: 'Kayu',
      primaryPractice: 'Skill, deep work, review pembelajaran',
    ),
    CultivationPalaceInfo(
      palace: CultivationPalace.joy,
      name: 'Joy Garden',
      domainKey: 'Rekreasi',
      element: 'Angin',
      primaryPractice: 'Hobi, seni, bermain, istirahat sadar',
    ),
  ];

  static const paths = <CultivationPathInfo>[
    CultivationPathInfo(
      path: CultivationPath.sword,
      name: 'Sword Path',
      core: 'Kejelasan, pemotongan ilusi',
      strength: 'Fokus tajam, tegas',
      shadowRisk: 'Kaku, dingin relasional',
    ),
    CultivationPathInfo(
      path: CultivationPath.alchemist,
      name: 'Alchemist Path',
      core: 'Penyulingan, transformasi halus',
      strength: 'Sabar, integratif',
      shadowRisk: 'Sulit tegas',
    ),
    CultivationPathInfo(
      path: CultivationPath.formation,
      name: 'Formation Path',
      core: 'Sistem, struktur, desain kehidupan',
      strength: 'Teratur, stabil',
      shadowRisk: 'Over-control',
    ),
    CultivationPathInfo(
      path: CultivationPath.body,
      name: 'Body Path',
      core: 'Ketahanan, eksekusi, disiplin fisik',
      strength: 'Action-oriented',
      shadowRisk: 'Mengabaikan emosi',
    ),
    CultivationPathInfo(
      path: CultivationPath.word,
      name: 'Word Path',
      core: 'Makna, bahasa, cerita',
      strength: 'Komunikatif',
      shadowRisk: 'Retorika tanpa aksi',
    ),
    CultivationPathInfo(
      path: CultivationPath.shadow,
      name: 'Shadow Path',
      core: 'Masuk ke area sulit: trauma, chaos',
      strength: 'Transformasi mendalam',
      shadowRisk: 'Terjebak kegelapan',
    ),
  ];

  static CultivationRealm realmForLevel(int level) {
    return realms.firstWhere(
      (realm) => realm.level == level,
      orElse: () => realms.first,
    );
  }

  static CultivationPalaceInfo palaceInfo(CultivationPalace palace) {
    return palaces.firstWhere((info) => info.palace == palace);
  }

  static CultivationPathInfo pathInfo(CultivationPath path) {
    return paths.firstWhere((info) => info.path == path);
  }
}
