import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';

class PublicTemplate {
  final String templateId;
  final String title;
  final String description;
  final String domainTag;
  final int friction;
  final int energy;
  final int impact;
  final int mvaDuration;
  final String creatorPenName;
  final int ratingsSum;
  final int ratingsCount;
  final int downloadsCount;
  final DateTime createdAt;

  PublicTemplate({
    required this.templateId,
    required this.title,
    required this.description,
    required this.domainTag,
    required this.friction,
    required this.energy,
    required this.impact,
    required this.mvaDuration,
    required String? creatorPenName,
    required this.ratingsSum,
    required this.ratingsCount,
    required this.downloadsCount,
    required this.createdAt,
  }) : creatorPenName = creatorPenName ?? 'Anonim';

  double get averageRating => ratingsCount == 0 ? 0.0 : ratingsSum / ratingsCount;

  PublicTemplate copyWith({
    String? title,
    String? description,
    String? domainTag,
    int? friction,
    int? energy,
    int? impact,
    int? mvaDuration,
    String? creatorPenName,
    int? ratingsSum,
    int? ratingsCount,
    int? downloadsCount,
  }) {
    return PublicTemplate(
      templateId: templateId,
      title: title ?? this.title,
      description: description ?? this.description,
      domainTag: domainTag ?? this.domainTag,
      friction: friction ?? this.friction,
      energy: energy ?? this.energy,
      impact: impact ?? this.impact,
      mvaDuration: mvaDuration ?? this.mvaDuration,
      creatorPenName: creatorPenName ?? this.creatorPenName,
      ratingsSum: ratingsSum ?? this.ratingsSum,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      createdAt: createdAt,
    );
  }
}

abstract class MarketplaceService {
  Future<List<PublicTemplate>> fetchTemplates({String? domain, String? query, String? sortBy});
  Future<void> uploadTemplate({
    required String title,
    required String description,
    required String domainTag,
    required int friction,
    required int energy,
    required int impact,
    required int mvaDuration,
    required String creatorPenName,
  });
  Future<void> rateTemplate(String templateId, int rating);
  Future<void> incrementDownloads(String templateId);
}

class LocalMarketplaceService implements MarketplaceService {
  final AppDatabase _db;
  LocalMarketplaceService(this._db);

  Future<void> _seedIfEmpty() async {
    final count = await (_db.select(_db.marketplaceTemplates)..limit(1)).get();
    if (count.isEmpty) {
      final initialTemplates = [
        MarketplaceTemplate(
          templateId: 'temp-1',
          title: 'Minum Segelas Air Hangat',
          description: 'Membantu rehidrasi instan organ dalam tubuh setelah bangun tidur pagi.',
          domainTag: 'Tubuh',
          friction: 1,
          energy: 1,
          impact: 4,
          mvaDuration: 1,
          creatorPenName: 'dr. Budi',
          ratingsSum: 48,
          ratingsCount: 10,
          downloadsCount: 342,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-2',
          title: 'Peregangan Leher & Bahu',
          description: 'Menghilangkan otot tegang dan kaku setelah duduk bekerja di depan komputer.',
          domainTag: 'Tubuh',
          friction: 1,
          energy: 2,
          impact: 3,
          mvaDuration: 2,
          creatorPenName: 'Coach Fitri',
          ratingsSum: 35,
          ratingsCount: 8,
          downloadsCount: 189,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-3',
          title: 'Plank Statis 1 Menit',
          description: 'Latihan kekuatan core otot perut dan stabilitas tulang belakang.',
          domainTag: 'Tubuh',
          friction: 2,
          energy: 3,
          impact: 4,
          mvaDuration: 1,
          creatorPenName: 'GymBro',
          ratingsSum: 72,
          ratingsCount: 15,
          downloadsCount: 412,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-4',
          title: 'Jalan Kaki Santai Sore',
          description: 'Meningkatkan sirkulasi darah dan menyegarkan paru-paru dengan udara luar.',
          domainTag: 'Tubuh',
          friction: 2,
          energy: 3,
          impact: 5,
          mvaDuration: 5,
          creatorPenName: 'Lestari',
          ratingsSum: 95,
          ratingsCount: 20,
          downloadsCount: 520,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-5',
          title: 'Latihan Napas Kotak (Box Breathing)',
          description: 'Teknik pernapasan taktis untuk menurunkan detak jantung dan meredakan cemas.',
          domainTag: 'Emosi',
          friction: 1,
          energy: 1,
          impact: 4,
          mvaDuration: 2,
          creatorPenName: 'ZenMind',
          ratingsSum: 88,
          ratingsCount: 18,
          downloadsCount: 310,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-6',
          title: 'Mencatat Syukur Harian',
          description: 'Menuliskan 3 hal kecil yang disyukuri hari ini untuk melatih emosi positif.',
          domainTag: 'Emosi',
          friction: 2,
          energy: 1,
          impact: 4,
          mvaDuration: 3,
          creatorPenName: 'GratefulSoul',
          ratingsSum: 120,
          ratingsCount: 25,
          downloadsCount: 615,
          createdAt: DateTime.now().subtract(const Duration(days: 75)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-7',
          title: 'Menyusun Anggaran Bulanan',
          description: 'Membuat alokasi pos pengeluaran di awal bulan menggunakan metode 50/30/20.',
          domainTag: 'Keuangan',
          friction: 3,
          energy: 2,
          impact: 5,
          mvaDuration: 5,
          creatorPenName: 'FinPlan',
          ratingsSum: 40,
          ratingsCount: 9,
          downloadsCount: 220,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-8',
          title: 'Telepon Sahabat Lama',
          description: 'Meluangkan waktu untuk menelpon teman lama guna menjaga tali silaturahmi.',
          domainTag: 'Hubungan',
          friction: 2,
          energy: 2,
          impact: 4,
          mvaDuration: 5,
          creatorPenName: 'SosialBuddy',
          ratingsSum: 45,
          ratingsCount: 10,
          downloadsCount: 180,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-9',
          title: 'Tinjau Inbox & Prioritas Kerja',
          description: 'Mengatur email masuk dan menyusun daftar prioritas kerja di pagi hari.',
          domainTag: 'Karir',
          friction: 2,
          energy: 2,
          impact: 4,
          mvaDuration: 3,
          creatorPenName: 'ProOrganized',
          ratingsSum: 55,
          ratingsCount: 12,
          downloadsCount: 290,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        MarketplaceTemplate(
          templateId: 'temp-10',
          title: 'Sesi Menggambar Bebas',
          description: 'Melakukan aktivitas kreatif ringan untuk melepas stres tanpa target hasil.',
          domainTag: 'Rekreasi',
          friction: 1,
          energy: 1,
          impact: 3,
          mvaDuration: 5,
          creatorPenName: 'ArtCalm',
          ratingsSum: 33,
          ratingsCount: 7,
          downloadsCount: 112,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ];
      await _db.batch((batch) {
        batch.insertAll(_db.marketplaceTemplates, initialTemplates);
      });
    }
  }

  @override
  Future<List<PublicTemplate>> fetchTemplates({String? domain, String? query, String? sortBy}) async {
    await _seedIfEmpty();
    final queryBuilder = _db.select(_db.marketplaceTemplates);
    if (domain != null && domain != 'Semua') {
      queryBuilder.where((t) => t.domainTag.equals(domain));
    }
    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim()}%';
      queryBuilder.where((t) => t.title.like(pattern) | t.description.like(pattern));
    }
    final results = await queryBuilder.get();
    final list = results.map((row) => PublicTemplate(
      templateId: row.templateId,
      title: row.title,
      description: row.description,
      domainTag: row.domainTag,
      friction: row.friction,
      energy: row.energy,
      impact: row.impact,
      mvaDuration: row.mvaDuration,
      creatorPenName: row.creatorPenName,
      ratingsSum: row.ratingsSum,
      ratingsCount: row.ratingsCount,
      downloadsCount: row.downloadsCount,
      createdAt: row.createdAt,
    )).toList();

    if (sortBy == 'Terpopuler') {
      list.sort((a, b) => b.downloadsCount.compareTo(a.downloadsCount));
    } else if (sortBy == 'Terbaik') {
      list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Future<void> uploadTemplate({
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
      title: title,
      description: description,
      domainTag: domainTag,
      friction: friction,
      energy: energy,
      impact: impact,
      mvaDuration: mvaDuration,
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
    await _seedIfEmpty();
    final selectQuery = _db.select(_db.marketplaceTemplates)..where((t) => t.templateId.equals(templateId));
    final template = await selectQuery.getSingleOrNull();
    if (template != null) {
      final updateCompanion = MarketplaceTemplatesCompanion(
        ratingsSum: Value(template.ratingsSum + rating),
        ratingsCount: Value(template.ratingsCount + 1),
      );
      final updateQuery = _db.update(_db.marketplaceTemplates)..where((t) => t.templateId.equals(templateId));
      await updateQuery.write(updateCompanion);
    }
  }

  @override
  Future<void> incrementDownloads(String templateId) async {
    await _seedIfEmpty();
    final selectQuery = _db.select(_db.marketplaceTemplates)..where((t) => t.templateId.equals(templateId));
    final template = await selectQuery.getSingleOrNull();
    if (template != null) {
      final updateCompanion = MarketplaceTemplatesCompanion(
        downloadsCount: Value(template.downloadsCount + 1),
      );
      final updateQuery = _db.update(_db.marketplaceTemplates)..where((t) => t.templateId.equals(templateId));
      await updateQuery.write(updateCompanion);
    }
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final db = ref.watch(dbProvider);
  return LocalMarketplaceService(db);
});
