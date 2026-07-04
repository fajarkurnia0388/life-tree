import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/theme/theme.dart';

class ReflectionDashboardTab extends ConsumerWidget {
  const ReflectionDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    final List<Map<String, dynamic>> reflectionFeatures = [
      {
        'title': DaojiText.resolve(DaojiTextKey.reflectionValueMirror, vocabularyLevel),
        'desc':
            'Jawab dilema ringan untuk melihat nilai apa yang sebenarnya kamu pegang lewat pilihan kecilmu.',
        'route': '/value-mirror',
        'icon': Icons.balance_rounded,
        'color': CalmTheme.secondaryBlue,
      },
      {
        'title': DaojiText.resolve(DaojiTextKey.reflectionWeeklyPulse, vocabularyLevel),
        'desc':
            'Evaluasi berkala 2 mingguan untuk meninjau kembali keseimbangan hidup Anda di seluruh domain.',
        'route': '/weekly-pulse',
        'icon': Icons.trending_up_rounded,
        'color': CalmTheme.primarySage,
      },
      {
        'title': DaojiText.resolve(DaojiTextKey.reflectionThinkingCanvas, vocabularyLevel),
        'desc':
            'Alat bantu analisis visual terstruktur (seperti Metode Kertas Kosong) untuk mengurai kerumitan pikiran.',
        'route': '/thinking-canvas',
        'icon': Icons.insights_rounded,
        'color': CalmTheme.secondaryBlue,
      },
      {
        'title': DaojiText.resolve(DaojiTextKey.reflectionSafetyCard, vocabularyLevel),
        'desc':
            'Panduan penanganan krisis keselamatan diri, kontak bantuan darurat, dan latihan rileksasi cemas.',
        'route': '/safety',
        'icon': Icons.shield_rounded,
        'color': CalmTheme.alertMutedRed,
      },
      {
        'title': DaojiText.resolve(DaojiTextKey.reflectionMarketplace, vocabularyLevel),
        'desc':
            'Temukan dan unduh kumpulan template kebiasaan berfaedah yang dibagikan oleh komunitas.',
        'route': '/marketplace',
        'icon': Icons.storefront_rounded,
        'color': CalmTheme.primarySage,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(DaojiText.resolve(DaojiTextKey.reflectionTitle, vocabularyLevel)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ruang Analisis & Dukungan',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              DaojiText.resolve(DaojiTextKey.reflectionSubtitle, vocabularyLevel),
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reflectionFeatures.length,
              itemBuilder: (context, index) {
                final feat = reflectionFeatures[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (feat['color'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        feat['icon'] as IconData,
                        color: feat['color'] as Color,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      feat['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        feat['desc'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(feat['route'] as String),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
