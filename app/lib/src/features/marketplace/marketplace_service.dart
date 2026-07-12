import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import 'models/marketplace_template_model.dart';

abstract class MarketplaceService {
  Future<List<MarketplaceTemplateModel>> fetchTemplates({
    String? templateType,
    String? domain,
    String? query,
    String? sortBy,
  });

  Future<void> uploadHabitTemplate({
    required String title,
    required String description,
    required String domainTag,
    required int friction,
    required int energy,
    required int impact,
    required int mvaDuration,
    required String creatorPenName,
  });

  Future<void> uploadCoreValueTemplate({
    required String title,
    required String description,
    required String emoji,
    required String whyItMatters,
    required List<String> relatedDomains,
    required String reflectionPrompt,
    required String creatorPenName,
  });

  Future<void> rateTemplate(String templateId, int rating);
  Future<void> incrementDownloads(String templateId);
}

class LocalMarketplaceService implements MarketplaceService {
  final AppDatabase _db;
  LocalMarketplaceService(this._db);

  bool _seeded = false;

  Future<void> _seedIfEmpty() async {
    if (_seeded) return;
    final count = await (_db.select(_db.marketplaceTemplates)..limit(1)).get();
    if (count.isNotEmpty) {
      _seeded = true;
      return;
    }

    final now = DateTime.now();
    final initialTemplates = [
      _habitTemplate(
        id: 'habit-temp-1',
        title: 'Minum Segelas Air Hangat',
        description:
            'Membantu rehidrasi instan organ dalam tubuh setelah bangun tidur pagi.',
        domainTag: 'Tubuh',
        friction: 1,
        energy: 1,
        impact: 4,
        mvaDuration: 1,
        creator: 'dr. Budi',
        ratingsSum: 48,
        ratingsCount: 10,
        downloadsCount: 342,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      _habitTemplate(
        id: 'habit-temp-2',
        title: 'Peregangan Leher & Bahu',
        description:
            'Menghilangkan otot tegang dan kaku setelah duduk bekerja di depan komputer.',
        domainTag: 'Tubuh',
        friction: 1,
        energy: 2,
        impact: 3,
        mvaDuration: 2,
        creator: 'Coach Fitri',
        ratingsSum: 35,
        ratingsCount: 8,
        downloadsCount: 189,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      _habitTemplate(
        id: 'habit-temp-3',
        title: 'Latihan Napas Kotak (Box Breathing)',
        description:
            'Teknik pernapasan taktis untuk menurunkan detak jantung dan meredakan cemas.',
        domainTag: 'Emosi',
        friction: 1,
        energy: 1,
        impact: 4,
        mvaDuration: 2,
        creator: 'ZenMind',
        ratingsSum: 88,
        ratingsCount: 18,
        downloadsCount: 310,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      _habitTemplate(
        id: 'habit-temp-4',
        title: 'Menyusun Anggaran Bulanan',
        description:
            'Membuat alokasi pos pengeluaran di awal bulan menggunakan metode 50/30/20.',
        domainTag: 'Keuangan',
        friction: 3,
        energy: 2,
        impact: 5,
        mvaDuration: 5,
        creator: 'FinPlan',
        ratingsSum: 40,
        ratingsCount: 9,
        downloadsCount: 220,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      _coreValueTemplate(
        id: 'value-temp-1',
        title: 'Kesehatan',
        description:
            'Menjaga tubuh dan energi sebagai fondasi aktivitas hidup.',
        emoji: '🏃',
        whyItMatters:
            'Kesehatan membantu Anda tetap punya tenaga untuk bekerja, belajar, dan hadir untuk orang penting.',
        relatedDomains: ['Tubuh', 'Emosi'],
        reflectionPrompt:
            'Apa satu keputusan kecil minggu ini yang akan menjaga energi tubuh Anda?',
        creator: 'LifeTree',
        ratingsSum: 50,
        ratingsCount: 10,
        downloadsCount: 240,
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      _coreValueTemplate(
        id: 'value-temp-2',
        title: 'Kebebasan',
        description:
            'Kemampuan memilih jalan hidup dengan sadar dan bertanggung jawab.',
        emoji: '🗽',
        whyItMatters:
            'Kebebasan memberi ruang untuk menentukan prioritas, batasan, dan arah hidup sendiri.',
        relatedDomains: ['Karir', 'Keuangan'],
        reflectionPrompt:
            'Di area mana Anda ingin punya lebih banyak ruang memilih?',
        creator: 'LifeTree',
        ratingsSum: 45,
        ratingsCount: 9,
        downloadsCount: 210,
        createdAt: now.subtract(const Duration(days: 16)),
      ),
      _coreValueTemplate(
        id: 'value-temp-3',
        title: 'Keluarga',
        description:
            'Merawat hubungan dekat yang memberi rasa pulang dan makna.',
        emoji: '👨‍👩‍👧',
        whyItMatters:
            'Keluarga atau orang terdekat sering menjadi alasan untuk bertahan, tumbuh, dan kembali seimbang.',
        relatedDomains: ['Hubungan', 'Emosi'],
        reflectionPrompt:
            'Apa bentuk kehadiran sederhana yang bisa Anda berikan minggu ini?',
        creator: 'LifeTree',
        ratingsSum: 60,
        ratingsCount: 12,
        downloadsCount: 260,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];

    await _db.batch((batch) {
      batch.insertAll(_db.marketplaceTemplates, initialTemplates);
    });
    _seeded = true;
  }

  MarketplaceTemplate _habitTemplate({
    required String id,
    required String title,
    required String description,
    required String domainTag,
    required int friction,
    required int energy,
    required int impact,
    required int mvaDuration,
    required String creator,
    required int ratingsSum,
    required int ratingsCount,
    required int downloadsCount,
    required DateTime createdAt,
  }) {
    return MarketplaceTemplate(
      templateId: id,
      templateType: 'habit',
      title: title,
      description: description,
      domainTag: domainTag,
      metadata: jsonEncode(
        HabitTemplateMetadata(
          friction: friction,
          energy: energy,
          impact: impact,
          mvaDuration: mvaDuration,
        ).toJson(),
      ),
      creatorPenName: creator,
      ratingsSum: ratingsSum,
      ratingsCount: ratingsCount,
      downloadsCount: downloadsCount,
      createdAt: createdAt,
    );
  }

  MarketplaceTemplate _coreValueTemplate({
    required String id,
    required String title,
    required String description,
    required String emoji,
    required String whyItMatters,
    required List<String> relatedDomains,
    required String reflectionPrompt,
    required String creator,
    required int ratingsSum,
    required int ratingsCount,
    required int downloadsCount,
    required DateTime createdAt,
  }) {
    return MarketplaceTemplate(
      templateId: id,
      templateType: 'core_value',
      title: title,
      description: description,
      domainTag: relatedDomains.isEmpty ? null : relatedDomains.first,
      metadata: jsonEncode(
        CoreValueTemplateMetadata(
          emoji: emoji,
          whyItMatters: whyItMatters,
          relatedDomains: relatedDomains,
          reflectionPrompt: reflectionPrompt,
        ).toJson(),
      ),
      creatorPenName: creator,
      ratingsSum: ratingsSum,
      ratingsCount: ratingsCount,
      downloadsCount: downloadsCount,
      createdAt: createdAt,
    );
  }

  @override
  Future<List<MarketplaceTemplateModel>> fetchTemplates({
    String? templateType,
    String? domain,
    String? query,
    String? sortBy,
  }) async {
    await _seedIfEmpty();
    final queryBuilder = _db.select(_db.marketplaceTemplates);

    if (templateType != null) {
      queryBuilder.where((t) => t.templateType.equals(templateType));
    }
    if (domain != null && domain != 'Semua') {
      queryBuilder.where((t) => t.domainTag.equals(domain));
    }
    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim()}%';
      queryBuilder.where(
        (t) => t.title.like(pattern) | t.description.like(pattern),
      );
    }

    final results = await queryBuilder.get();
    final list = results.map(_toModel).toList();

    if (sortBy == 'Terpopuler') {
      list.sort((a, b) => b.downloadsCount.compareTo(a.downloadsCount));
    } else if (sortBy == 'Terbaik') {
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  MarketplaceTemplateModel _toModel(MarketplaceTemplate row) {
    return MarketplaceTemplateModel(
      templateId: row.templateId,
      templateType: row.templateType,
      title: row.title,
      description: row.description,
      domainTag: row.domainTag,
      metadata: TemplateMetadata.fromJson(row.templateType, row.metadata),
      creatorPenName: row.creatorPenName,
      ratingsSum: row.ratingsSum,
      ratingsCount: row.ratingsCount,
      downloadsCount: row.downloadsCount,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> uploadHabitTemplate({
    required String title,
    required String description,
    required String domainTag,
    required int friction,
    required int energy,
    required int impact,
    required int mvaDuration,
    required String creatorPenName,
  }) async {
    await _seedIfEmpty();
    final newId = const Uuid().v4();
    final companion = MarketplaceTemplatesCompanion.insert(
      templateId: newId,
      templateType: 'habit',
      title: title,
      description: description,
      domainTag: Value(domainTag),
      metadata: Value(
        jsonEncode(
          HabitTemplateMetadata(
            friction: friction,
            energy: energy,
            impact: impact,
            mvaDuration: mvaDuration,
          ).toJson(),
        ),
      ),
      creatorPenName: creatorPenName.trim().isEmpty ? 'Anonim' : creatorPenName,
      ratingsSum: 5,
      ratingsCount: 1,
      downloadsCount: 1,
      createdAt: DateTime.now(),
    );
    await _db.into(_db.marketplaceTemplates).insert(companion);
  }

  @override
  Future<void> uploadCoreValueTemplate({
    required String title,
    required String description,
    required String emoji,
    required String whyItMatters,
    required List<String> relatedDomains,
    required String reflectionPrompt,
    required String creatorPenName,
  }) async {
    await _seedIfEmpty();
    final newId = const Uuid().v4();
    final companion = MarketplaceTemplatesCompanion.insert(
      templateId: newId,
      templateType: 'core_value',
      title: title,
      description: description,
      domainTag: Value(relatedDomains.isEmpty ? null : relatedDomains.first),
      metadata: Value(
        jsonEncode(
          CoreValueTemplateMetadata(
            emoji: emoji,
            whyItMatters: whyItMatters,
            relatedDomains: relatedDomains,
            reflectionPrompt: reflectionPrompt,
          ).toJson(),
        ),
      ),
      creatorPenName: creatorPenName.trim().isEmpty ? 'Anonim' : creatorPenName,
      ratingsSum: 5,
      ratingsCount: 1,
      downloadsCount: 1,
      createdAt: DateTime.now(),
    );
    await _db.into(_db.marketplaceTemplates).insert(companion);
  }

  @override
  Future<void> rateTemplate(String templateId, int rating) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Must be between 1 and 5');
    }
    await _seedIfEmpty();
    await _db.customUpdate(
      'UPDATE marketplace_templates '
      'SET ratings_sum = ratings_sum + ?, ratings_count = ratings_count + 1 '
      'WHERE template_id = ?',
      variables: [Variable<int>(rating), Variable<String>(templateId)],
      updates: {_db.marketplaceTemplates},
    );
  }

  @override
  Future<void> incrementDownloads(String templateId) async {
    await _seedIfEmpty();
    await _db.customUpdate(
      'UPDATE marketplace_templates '
      'SET downloads_count = downloads_count + 1 WHERE template_id = ?',
      variables: [Variable<String>(templateId)],
      updates: {_db.marketplaceTemplates},
    );
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final db = ref.watch(dbProvider);
  return LocalMarketplaceService(db);
});
