import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/widgets/loading_state_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/services/error_handler_service.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'widgets/create_decision_sheet.dart';
import 'widgets/review_decision_sheet.dart';

// Stream provider to automatically watch decisions in database
final decisionListProvider = StreamProvider<List<DecisionEntry>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.decisionEntries)
        ..where((tbl) => tbl.deletedAt.isNull())
        ..orderBy([
          (tbl) => drift.OrderingTerm(
            expression: tbl.decisionDate,
            mode: drift.OrderingMode.desc,
          ),
        ]))
      .watch();
});

class DecisionJournalView extends ConsumerStatefulWidget {
  const DecisionJournalView({super.key});

  @override
  ConsumerState<DecisionJournalView> createState() =>
      _DecisionJournalViewState();
}

class _DecisionJournalViewState extends ConsumerState<DecisionJournalView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateDecisionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const CreateDecisionSheet();
      },
    ).then((_) {
      ref.invalidate(decisionListProvider);
    });
  }

  void _showReviewDecisionDialog(BuildContext context, DecisionEntry decision) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReviewDecisionSheet(decision: decision);
      },
    ).then((_) {
      ref.invalidate(decisionListProvider);
      ref.invalidate(dashboardDataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final theme = Theme.of(context);
    final decisionsAsync = ref.watch(decisionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DaojiText.resolve(DaojiTextKey.decisionTitle, vocabularyLevel)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          tabs: const [
            Tab(text: 'Menunggu Review'),
            Tab(text: 'Sudah Ditinjau'),
          ],
        ),
      ),
      body: decisionsAsync.when(
        data: (decisions) {
          final pending = decisions.where((d) => !d.isReviewed).toList();
          final reviewed = decisions.where((d) => d.isReviewed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDecisionList(context, pending, isPending: true),
              _buildDecisionList(context, reviewed, isPending: false),
            ],
          );
        },
        loading: () => Center(
          child: LoadingStateWidget(message: 'Memuat jurnal keputusan...'),
        ),
        error: (err, stack) => Center(child: Text('Gagal memuat jurnal: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDecisionDialog(context),
        label: const Text('Catat Keputusan'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDecisionList(
    BuildContext context,
    List<DecisionEntry> list, {
    required bool isPending,
  }) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: isPending ? Icons.pending_actions : Icons.check_circle_outline,
        title: isPending
            ? 'Tidak Ada Keputusan Pending'
            : 'Belum Ada Keputusan Selesai',
        message: isPending
            ? 'Keputusan yang perlu ditinjau akan muncul di sini'
            : 'Keputusan yang sudah direview akan muncul di sini',
        actionLabel: isPending ? 'Buat Keputusan Baru' : null,
        onAction: isPending ? () => _showCreateDecisionDialog(context) : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final d = list[index];
        final isOverdue = !d.isReviewed && DateTime.now().isAfter(d.reviewDate);

        List<String> options = [];
        List<String> assumptions = [];
        try {
          options = List<String>.from(jsonDecode(d.options));
          assumptions = List<String>.from(jsonDecode(d.assumptions));
        } catch (e, stackTrace) {
          ErrorHandlerService().logError(
            e,
            stackTrace,
            context: 'DecisionJournalView.parseDecisionData',
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOverdue
                  ? theme.colorScheme.error.withValues(alpha: 0.4)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: isOverdue ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        d.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'JATUH TEMPO REVIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  d.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Divider(height: 24),
                if (options.length >= 2) ...[
                  const Text(
                    'Pilihan yang Dipertimbangkan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⚖️ Opsi A: ${options[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '⚖️ Opsi B: ${options[1]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ],
                if (assumptions.isNotEmpty) ...[
                  const Text(
                    'Asumsi/Keyakinan Utama:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  ...assumptions.map(
                    (asm) => Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                      child: Text(
                        '• $asm',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Ekspektasi Hasil:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  d.expectations,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Keputusan: ${_formatDate(d.decisionDate)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          'Tanggal Review: ${_formatDate(d.reviewDate)} (${d.reviewPeriodDays} hari)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _showReviewDecisionDialog(context, d),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          foregroundColor: isOverdue
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(100, 36),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!isPending && d.reviewReflection != null) ...[
                  const Divider(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📝', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Hasil & Refleksi 90 Hari:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.reviewReflection!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
