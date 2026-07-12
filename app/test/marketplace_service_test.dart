import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/marketplace/marketplace_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late MarketplaceService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
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
      expect(templates.length, 7); // 4 habits + 3 core values

      final habitTemplates = templates.where((t) => t.isHabit).toList();
      expect(habitTemplates.length, 4);

      final first = templates.firstWhere((t) => t.templateId == 'habit-temp-1');
      expect(first.title, 'Minum Segelas Air Hangat');
      expect(first.domainTag, 'Tubuh');
      expect(first.creatorPenName, 'dr. Budi');
    });

    test('Filter berdasarkan domain', () async {
      final bodyTemplates = await service.fetchTemplates(domain: 'Tubuh');
      expect(bodyTemplates.every((t) => t.domainTag == 'Tubuh'), isTrue);
      expect(
        bodyTemplates.length,
        3,
      ); // habit-temp-1, habit-temp-2, value-temp-1 (Kesehatan)
    });

    test('Filter berdasarkan template type', () async {
      final habitTemplates = await service.fetchTemplates(
        templateType: 'habit',
      );
      expect(habitTemplates.every((t) => t.isHabit), isTrue);
      expect(habitTemplates.length, 4);

      final coreValueTemplates = await service.fetchTemplates(
        templateType: 'core_value',
      );
      expect(coreValueTemplates.every((t) => t.isCoreValue), isTrue);
      expect(coreValueTemplates.length, 3);
    });

    test('Pencarian berdasarkan query', () async {
      final results = await service.fetchTemplates(query: 'hangat');
      expect(results.length, 1);
      expect(results.first.templateId, 'habit-temp-1');
    });

    test('Upload habit template baru', () async {
      await service.uploadHabitTemplate(
        title: 'Kebiasaan Baru Saya',
        description: 'Deskripsi kebiasaan baru',
        domainTag: 'Karir',
        friction: 2,
        energy: 2,
        impact: 4,
        mvaDuration: 10,
        creatorPenName: 'Penulis Tes',
      );

      final templates = await service.fetchTemplates(
        templateType: 'habit',
        domain: 'Karir',
      );
      final myTemplate = templates.firstWhere(
        (t) => t.title == 'Kebiasaan Baru Saya',
      );
      expect(myTemplate.creatorPenName, 'Penulis Tes');
      expect(myTemplate.description, 'Deskripsi kebiasaan baru');
      expect(myTemplate.habitMetadata?.mvaDuration, 10);
      expect(myTemplate.habitMetadata?.friction, 2);
      expect(myTemplate.habitMetadata?.energy, 2);
      expect(myTemplate.habitMetadata?.impact, 4);
    });

    test('Upload core value template baru', () async {
      await service.uploadCoreValueTemplate(
        title: 'Integritas',
        description: 'Konsisten antara kata dan perbuatan',
        emoji: '🛡️',
        whyItMatters: 'Integritas membangun kepercayaan jangka panjang',
        relatedDomains: ['Karir', 'Hubungan'],
        reflectionPrompt: 'Kapan terakhir saya menepati janji meski sulit?',
        creatorPenName: 'Penulis Tes',
      );

      final templates = await service.fetchTemplates(
        templateType: 'core_value',
      );
      final myTemplate = templates.firstWhere((t) => t.title == 'Integritas');
      expect(myTemplate.creatorPenName, 'Penulis Tes');
      expect(myTemplate.description, 'Konsisten antara kata dan perbuatan');
      expect(myTemplate.coreValueMetadata?.emoji, '🛡️');
      expect(
        myTemplate.coreValueMetadata?.whyItMatters,
        'Integritas membangun kepercayaan jangka panjang',
      );
      expect(myTemplate.coreValueMetadata?.relatedDomains, [
        'Karir',
        'Hubungan',
      ]);
    });

    test('Rating template', () async {
      // Bundled templates start with honest zero social metrics.
      final initial = (await service.fetchTemplates()).firstWhere(
        (t) => t.templateId == 'habit-temp-1',
      );
      expect(initial.ratingsSum, 0);
      expect(initial.ratingsCount, 0);

      // Rate with 5 stars
      await service.rateTemplate('habit-temp-1', 5);

      final updated = (await service.fetchTemplates()).firstWhere(
        (t) => t.templateId == 'habit-temp-1',
      );
      expect(updated.ratingsSum, 5);
      expect(updated.ratingsCount, 1);
      expect(updated.averageRating, 5.0);
    });

    test('Increment download count', () async {
      final initial = (await service.fetchTemplates()).firstWhere(
        (t) => t.templateId == 'habit-temp-2',
      );
      expect(initial.downloadsCount, 0);

      await service.incrementDownloads('habit-temp-2');

      final updated = (await service.fetchTemplates()).firstWhere(
        (t) => t.templateId == 'habit-temp-2',
      );
      expect(updated.downloadsCount, 1);
    });
  });
}
