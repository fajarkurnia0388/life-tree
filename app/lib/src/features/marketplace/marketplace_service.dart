import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
    required this.creatorPenName,
    required this.ratingsSum,
    required this.ratingsCount,
    required this.downloadsCount,
    required this.createdAt,
  });

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

class MockMarketplaceService implements MarketplaceService {
  final List<PublicTemplate> _templates = [
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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
    PublicTemplate(
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

  @override
  Future<List<PublicTemplate>> fetchTemplates({String? domain, String? query, String? sortBy}) async {
    // Simulate networking delay
    await Future.delayed(const Duration(milliseconds: 300));

    Iterable<PublicTemplate> list = _templates;

    // Filter by domain
    if (domain != null && domain != 'Semua') {
      list = list.where((t) => t.domainTag.toLowerCase() == domain.toLowerCase());
    }

    // Search query
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q));
    }

    final sorted = list.toList();

    // Sort
    if (sortBy == 'Terpopuler') {
      sorted.sort((a, b) => b.downloadsCount.compareTo(a.downloadsCount));
    } else if (sortBy == 'Terbaik') {
      sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    } else {
      // Terbaru
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sorted;
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
    await Future.delayed(const Duration(milliseconds: 300));
    _templates.add(
      PublicTemplate(
        templateId: const Uuid().v4(),
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
      ),
    );
  }

  @override
  Future<void> rateTemplate(String templateId, int rating) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _templates.indexWhere((t) => t.templateId == templateId);
    if (idx != -1) {
      final t = _templates[idx];
      _templates[idx] = t.copyWith(
        ratingsSum: t.ratingsSum + rating,
        ratingsCount: t.ratingsCount + 1,
      );
    }
  }

  @override
  Future<void> incrementDownloads(String templateId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _templates.indexWhere((t) => t.templateId == templateId);
    if (idx != -1) {
      final t = _templates[idx];
      _templates[idx] = t.copyWith(
        downloadsCount: t.downloadsCount + 1,
      );
    }
  }
}

// TODO: MockMarketplaceService hanya menyimpan data di memori (volatile).
// Implementasikan RemoteMarketplaceService menggunakan Supabase/Firebase
// atau LocalMarketplaceService menggunakan drift untuk persisten data.
final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MockMarketplaceService(); // MOCK ONLY — not production-ready
});
