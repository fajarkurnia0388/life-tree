import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import 'dart:convert';
import '../../core/theme/theme.dart';
import '../../data/local_db/database.dart';
import 'widgets/palace_sparkline_widget.dart';
import '../profile/widgets/domain_re_audit_dialog.dart';
import '../profile/widgets/compass_comparison_dialog.dart';
import '../dashboard/dashboard_provider.dart';

class ReflectionDashboardTab extends ConsumerStatefulWidget {
  const ReflectionDashboardTab({super.key});

  @override
  ConsumerState<ReflectionDashboardTab> createState() =>
      _ReflectionDashboardTabState();
}

class _ReflectionDashboardTabState extends ConsumerState<ReflectionDashboardTab> {
  Future<void> _showDomainReauditDialog(
    BuildContext context,
    UserProfile profile,
  ) async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => DomainReAuditDialog(profile: profile),
    );

    if (result != null) {
      final db = ref.read(dbProvider);
      final newScoresJson = jsonEncode(result);

      try {
        await (db.update(
          db.userProfiles,
        )..where((t) => t.userId.equals(profile.userId))).write(
          UserProfilesCompanion(
            latestDomainScores: drift.Value(newScoresJson),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );

        await db
            .into(db.lifeAudits)
            .insert(
              LifeAuditsCompanion.insert(
                auditId: const Uuid().v4(),
                userId: profile.userId,
                domainScores: newScoresJson,
                timestamp: DateTime.now(),
              ),
            );

        ref.invalidate(dashboardDataProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Penilaian domain berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCompassComparisonDialog(BuildContext context, UserProfile profile) {
    // Parse declared values
    List<String> declaredValues = [];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        declaredValues = List<String>.from(jsonDecode(jsonStr));
      }
    } catch (_) {}

    // Parse revealed values
    int totalResponses = 0;
    Map<String, int> revealedScores = {};
    if (profile.revealedValueScores != null) {
      try {
        final Map<String, dynamic> raw = jsonDecode(
          profile.revealedValueScores!,
        );
        raw.forEach((key, val) {
          revealedScores[key] = val as int;
          totalResponses += revealedScores[key]!;
        });
      } catch (_) {}
    }

    final hasEnoughData = totalResponses >= 5;
    List<String> revealedValues = [];
    if (hasEnoughData) {
      final sortedRevealed = revealedScores.entries.toList()
        ..sort((a, b) {
          final cmp = b.value.compareTo(a.value);
          if (cmp != 0) return cmp;
          return a.key.compareTo(b.key);
        });
      revealedValues = sortedRevealed.take(3).map((e) => e.key).toList();
    }

    showDialog(
      context: context,
      builder: (context) => CompassComparisonDialog(
        profile: profile,
        declaredValues: declaredValues,
        revealedValues: revealedValues,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final historyAsync = ref.watch(lifeAuditsHistoryProvider);

    final profile = profileAsync.valueOrNull;
    final List<LifeAudit> history = historyAsync.valueOrNull ?? [];

    Map<String, dynamic> domainScores = {};
    if (profile != null && profile.latestDomainScores != null) {
      try {
        domainScores = jsonDecode(profile.latestDomainScores!);
      } catch (_) {}
    }

    final domains = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
    final domainColors = {
      'Tubuh': CalmTheme.primarySage,
      'Keuangan': CalmTheme.daoGold,
      'Hubungan': CalmTheme.alertMutedRed,
      'Emosi': CalmTheme.secondaryBlue,
      'Karir': CalmTheme.secondaryBlue,
      'Rekreasi': CalmTheme.primarySage,
    };

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
        'title': DaojiText.resolve(DaojiTextKey.reflectionCompassCompareAction, vocabularyLevel),
        'desc':
            'Bandingkan nilai pilihan sadar Anda dengan nilai tersembunyi yang tercermin dari tindakan kecil Anda.',
        'action': (BuildContext ctx, UserProfile p) => _showCompassComparisonDialog(ctx, p),
        'icon': Icons.explore_rounded,
        'color': CalmTheme.primarySage,
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
            if (profile != null) ...[
              ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tren Keseimbangan Istana Batin',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextButton.icon(
                      onPressed: () => _showDomainReauditDialog(context, profile),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        DaojiText.resolve(
                          DaojiTextKey.reflectionReauditAction,
                          vocabularyLevel,
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
                leading: const Icon(Icons.insights_rounded, color: Colors.teal),
                children: domains.map((d) {
                  final currentVal = (domainScores[d] as num?)?.toDouble() ?? 5.0;
                  
                  // Get real historical scores from life audits history
                  final List<double> scores = [];
                  for (final audit in history) {
                    try {
                      final Map<String, dynamic> parsed = jsonDecode(audit.domainScores);
                      final val = parsed[d];
                      if (val is num) {
                        scores.add(val.toDouble());
                      }
                    } catch (_) {}
                  }
                  if (scores.isEmpty) {
                    scores.add(currentVal);
                  }

                  final displayName = DaojiText.domainLabel(d, vocabularyLevel);

                  return PalaceSparklineWidget(
                    title: displayName,
                    scores: scores,
                    color: domainColors[d] ?? Colors.grey,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
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
                    onTap: () {
                      if (feat['action'] != null) {
                        (feat['action'] as Function(BuildContext, UserProfile))(context, profile!);
                      } else {
                        context.push(feat['route'] as String);
                      }
                    },
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
