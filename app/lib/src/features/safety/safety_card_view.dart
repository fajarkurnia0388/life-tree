import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../../core/theme/theme.dart';
import '../../core/domain/app_constants.dart';

class SafetyCardView extends ConsumerWidget {
  const SafetyCardView({super.key});

  Future<void> _logHotlineTap(WidgetRef ref, String serviceName) async {
    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Get user id
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    // Log the interaction locally
    await db.into(db.wellnessPromptLogs).insert(
          WellnessPromptLogsCompanion.insert(
            promptId: const Uuid().v4(),
            userId: userId,
            triggerType: WellnessPromptTrigger.safetyCard,
            promptedAt: now,
            userAction: const drift.Value('Tapped_Hotline_CTA'),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dukungan Kesehatan Diri'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe space header
            const Center(
              child: Text('🛡️', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 16),
            Text(
              'Pusat Dukungan & Bantuan',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Jika Anda merasa sangat kewalahan, berada dalam kondisi krisis emosional, atau membutuhkan pertolongan darurat, ketuk kontak di bawah ini untuk terhubung dengan layanan bantuan profesional.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),

            // Anti-banner blindness rotating colors selection
            () {
              final accentColors = theme.brightness == Brightness.dark
                  ? const [
                      CalmTheme.primarySageDark,
                      CalmTheme.secondaryBlueDark,
                      Color(0xFFE29E8C),
                      Color(0xFFDEC58D),
                      Color(0xFFDE9595),
                    ]
                  : const [
                      CalmTheme.primarySage,
                      CalmTheme.secondaryBlue,
                      Color(0xFFC48B7A),
                      Color(0xFFC2B280),
                      CalmTheme.alertMutedRed,
                    ];
              
              final index1 = DateTime.now().day % accentColors.length;
              final index2 = (index1 + 2) % accentColors.length;
              final color1 = accentColors[index1];
              final color2 = accentColors[index2];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hotline 1: SEJIWA (119 ext 8)
                  _buildHotlineCard(
                    theme: theme,
                    title: 'Layanan Kesehatan Jiwa SEJIWA (Healing119)',
                    number: '119 (Ekstensi 8)',
                    description: 'Layanan konseling psikologis darurat bebas biaya dari Pemerintah Indonesia. Terintegrasi dengan platform Healing119.id.',
                    color: color1,
                    onTap: () async {
                      await _logHotlineTap(ref, 'SEJIWA_Call');
                      final uri = Uri.parse('tel:119');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          _showCallMockDialog(context, 'Layanan SEJIWA (119 Ext 8)');
                        }
                      }
                    },
                    additionalActions: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _logHotlineTap(ref, 'SEJIWA_WhatsApp');
                              final url = Uri.parse(
                                'https://api.whatsapp.com/send/?phone=6281380073120&text=halo%20kak%2C%20saya%20ingin%20bercerita%20mengenai...&type=phone_number&app_absent=0',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.chat_outlined, size: 16),
                            label: const Text('Chat WhatsApp', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: color1),
                              foregroundColor: color1,
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _logHotlineTap(ref, 'SEJIWA_Website');
                              final url = Uri.parse('https://www.healing119.id/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.language_rounded, size: 16),
                            label: const Text('Buka Website', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: color1),
                              foregroundColor: color1,
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hotline 2: PSC 119
                  _buildHotlineCard(
                    theme: theme,
                    title: 'Pusat Krisis Kedaruratan PSC (Layanan Medis)',
                    number: '119',
                    description: 'Nomor darurat nasional terpadu untuk ambulans dan layanan medis darurat.',
                    color: color2,
                    onTap: () async {
                      await _logHotlineTap(ref, 'PSC 119');
                      final uri = Uri.parse('tel:119');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (context.mounted) {
                          _showCallMockDialog(context, 'Pusat Medis Darurat PSC (119)');
                        }
                      }
                    },
                  ),
                ],
              );
            }(),
            const SizedBox(height: 32),

            // Disclaimer card
            Card(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Text(
                          'Data Tersimpan Lokal di Perangkat Anda',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daoji menyimpan semua data secara offline pada memori internal perangkat Anda — tidak ada yang diunggah ke internet atau dibagikan ke pihak ketiga. Enkripsi database (SQLCipher) direncanakan pada fase berikutnya.',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotlineCard({
    required ThemeData theme,
    required String title,
    required String number,
    required String description,
    required Color color,
    required VoidCallback onTap,
    Widget? additionalActions,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.phone_rounded),
              label: Text('Hubungi $number'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: theme.colorScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
                minimumSize: const Size(88, 48), // WCAG touch target
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (additionalActions != null) ...[
              const SizedBox(height: 12),
              additionalActions,
            ],
          ],
        ),
      ),
    );
  }

  void _showCallMockDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Menghubungi Layanan...'),
          content: Text(
            'Aplikasi sedang membuka dialer telepon Anda untuk menghubungi:\n\n'
            '$serviceName\n\n'
            '(Interaksi ini telah dicatat di database lokal sebagai Tapped_Hotline_CTA).'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
