import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';

class ReflectionDashboardTab extends StatelessWidget {
  const ReflectionDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> reflectionFeatures = [
      {
        'title': 'Weekly Pulse 📈',
        'desc': 'Evaluasi berkala 2 mingguan untuk meninjau kembali keseimbangan hidup Anda di seluruh domain.',
        'route': '/weekly-pulse',
        'icon': Icons.trending_up_rounded,
        'color': CalmTheme.primarySage,
      },
      {
        'title': 'Thinking Canvas 🧠',
        'desc': 'Alat bantu analisis visual terstruktur (seperti Metode Kertas Kosong) untuk mengurai kerumitan pikiran.',
        'route': '/thinking-canvas',
        'icon': Icons.insights_rounded,
        'color': CalmTheme.secondaryBlue,
      },
      {
        'title': 'Safety Card 🛡️',
        'desc': 'Panduan penanganan krisis keselamatan diri, kontak bantuan darurat, dan latihan rileksasi cemas.',
        'route': '/safety',
        'icon': Icons.shield_rounded,
        'color': CalmTheme.alertMutedRed,
      },
      {
        'title': 'Habit Marketplace 🛒',
        'desc': 'Temukan dan unduh kumpulan template kebiasaan berfaedah yang dibagikan oleh komunitas.',
        'route': '/marketplace',
        'icon': Icons.storefront_rounded,
        'color': CalmTheme.primarySage,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refleksi Diri 🧘'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ruang Analisis & Dukungan',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Luangkan waktu sejenak untuk meninjau pola pikiran, kebiasaan, dan kondisi mental Anda.',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (feat['color'] as Color).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(feat['icon'] as IconData, color: feat['color'] as Color, size: 28),
                    ),
                    title: Text(
                      feat['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        feat['desc'] as String,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
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
