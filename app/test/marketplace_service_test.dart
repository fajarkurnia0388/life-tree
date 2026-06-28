import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';
import 'package:life_tree/src/features/marketplace/marketplace_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late MarketplaceService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
    service = container.read(marketplaceServiceProvider);
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  group('LocalMarketplaceService Tests', () {
    test('Seeding otomatis saat database kosong', () async {
      final templates = await service.fetchTemplates();
      expect(templates.length, 10);
      
      final first = templates.firstWhere((t) => t.templateId == 'temp-1');
      expect(first.title, 'Minum Segelas Air Hangat');
      expect(first.domainTag, 'Tubuh');
      expect(first.creatorPenName, 'dr. Budi');
    });

    test('Filter berdasarkan domain', () async {
      final bodyTemplates = await service.fetchTemplates(domain: 'Tubuh');
      expect(bodyTemplates.every((t) => t.domainTag == 'Tubuh'), isTrue);
      expect(bodyTemplates.length, 4); // temp-1, temp-2, temp-3, temp-4
    });

    test('Pencarian berdasarkan query', () async {
      final results = await service.fetchTemplates(query: 'hangat');
      expect(results.length, 1);
      expect(results.first.templateId, 'temp-1');
    });

    test('Upload template baru', () async {
      await service.uploadTemplate(
        title: 'Kebiasaan Baru Saya',
        description: 'Deskripsi kebiasaan baru',
        domainTag: 'Karir',
        friction: 2,
        energy: 2,
        impact: 4,
        mvaDuration: 10,
        creatorPenName: 'Penulis Tes',
      );

      final templates = await service.fetchTemplates(domain: 'Karir');
      final myTemplate = templates.firstWhere((t) => t.title == 'Kebiasaan Baru Saya');
      expect(myTemplate.creatorPenName, 'Penulis Tes');
      expect(myTemplate.description, 'Deskripsi kebiasaan baru');
      expect(myTemplate.mvaDuration, 10);
    });

    test('Rating template', () async {
      // temp-1 averageRating awal: 48 / 10 = 4.8
      final initial = (await service.fetchTemplates()).firstWhere((t) => t.templateId == 'temp-1');
      expect(initial.ratingsSum, 48);
      expect(initial.ratingsCount, 10);

      // Rate dengan 5 bintang
      await service.rateTemplate('temp-1', 5);

      final updated = (await service.fetchTemplates()).firstWhere((t) => t.templateId == 'temp-1');
      expect(updated.ratingsSum, 53);
      expect(updated.ratingsCount, 11);
      expect(updated.averageRating, 53 / 11);
    });

    test('Increment download count', () async {
      final initial = (await service.fetchTemplates()).firstWhere((t) => t.templateId == 'temp-2');
      expect(initial.downloadsCount, 189);

      await service.incrementDownloads('temp-2');

      final updated = (await service.fetchTemplates()).firstWhere((t) => t.templateId == 'temp-2');
      expect(updated.downloadsCount, 190);
    });
  });
}
