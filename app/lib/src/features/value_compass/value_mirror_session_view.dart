import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../core/providers/db_provider.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/button_theme.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_state_widget.dart';
import 'domain/value_dilemma.dart';
import 'services/value_compass_service.dart';
import 'widgets/value_dilemma_card.dart';
import 'widgets/value_open_question_card.dart';
import 'widgets/value_mirror_summary_sheet.dart';
import '../dashboard/dashboard_provider.dart';

class ValueMirrorSessionView extends ConsumerStatefulWidget {
  const ValueMirrorSessionView({super.key});

  @override
  ConsumerState<ValueMirrorSessionView> createState() =>
      _ValueMirrorSessionViewState();
}

class _ValueMirrorSessionViewState
    extends ConsumerState<ValueMirrorSessionView> {
  late final Future<List<dynamic>> _sessionFuture;
  final _pageController = PageController();
  int _currentIndex = 0;
  bool _isSaving = false;

  // Track session progress for draft
  final Set<String> _answeredKeys = {};

  @override
  void initState() {
    super.initState();
    _sessionFuture = _loadSession();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _loadSession() async {
    final db = ref.read(dbProvider);
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    try {
      final recent =
          await (db.select(db.valueDilemmaResponses)..where(
                (tbl) =>
                    tbl.answeredAt.isBiggerOrEqualValue(sevenDaysAgo) &
                    tbl.deletedAt.isNull(),
              ))
              .get();
      final excludeKeys = recent.map((r) => r.dilemmaKey).toSet();
      return ValueDilemmaPool.drawSession(excludeKeys: excludeKeys);
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'ValueMirrorSessionView.loadRecentResponses',
      );
      return ValueDilemmaPool.drawSession();
    }
  }

  Future<void> _handleBinaryAnswer(
    ValueDilemma dilemma,
    String option,
    String valueTag,
    int totalCards,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final db = ref.read(dbProvider);
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception("Profil tidak ditemukan.");
      final userId = profiles.first.userId;

      final service = ref.read(valueCompassServiceProvider);
      await service.recordBinaryResponse(
        userId: userId,
        dilemmaKey: dilemma.key,
        chosenOptionLabel: option,
        chosenValueTag: valueTag,
      );

      // Invalidate providers to refresh dashboard/profile
      ref.invalidate(revealedValuesProvider);
      ref.invalidate(dashboardDataProvider);

      // Track answered question
      _answeredKeys.add(dilemma.key);

      _nextPage(totalCards);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jawaban: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleOpenAnswer(
    OpenValueQuestion question,
    String text,
    int totalCards,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final db = ref.read(dbProvider);
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception("Profil tidak ditemukan.");
      final userId = profiles.first.userId;

      final service = ref.read(valueCompassServiceProvider);
      if (text.isNotEmpty) {
        await service.recordOpenResponse(
          userId: userId,
          dilemmaKey: question.key,
          text: text,
        );
      }

      // Track answered question
      _answeredKeys.add(question.key);

      _nextPage(totalCards);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jawaban: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _nextPage(int totalCards) {
    if (_currentIndex < totalCards - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishSession();
    }
  }

  Future<void> _finishSession() async {
    setState(() => _isSaving = true);
    try {
      final db = ref.read(dbProvider);
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) return;
      final profile = profiles.first;

      final service = ref.read(valueCompassServiceProvider);
      final topValues = await service.getTopRevealedValues(profile: profile);

      int totalResponses = 0;
      if (profile.revealedValueScores != null) {
        try {
          final Map<String, dynamic> raw = jsonDecode(
            profile.revealedValueScores!,
          );
          for (final v in raw.values) {
            totalResponses += v as int;
          }
        } catch (e, stackTrace) {
          ErrorHandlerService().logError(
            e,
            stackTrace,
            context: 'ValueMirrorSessionView.parseRevealedValueScores',
          );
        }
      }

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (context) {
            return ValueMirrorSummarySheet(
              revealedValues: topValues,
              totalResponses: totalResponses,
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan sesi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cermin Nilai 🪞'),
        leading: Semantics(
          label: 'Keluar dari sesi',
          hint: 'Menutup sesi refleksi Value Mirror',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Keluar dari Sesi?'),
                    content: Text(
                      _answeredKeys.isEmpty
                          ? 'Anda belum menjawab pertanyaan apapun. Yakin ingin keluar?'
                          : 'Anda telah menjawab ${_answeredKeys.length} pertanyaan. Progres sudah tersimpan otomatis. Yakin ingin keluar?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: AppButtonStyles.text(context),
                        child: const Text('Lanjutkan'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          context.go('/');
                        },
                        style: AppButtonStyles.destructive(context).copyWith(
                          backgroundColor: WidgetStateProperty.all(
                            CalmTheme.alertMutedRed,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            Colors.white,
                          ),
                        ),
                        child: const Text('Keluar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingStateWidget(message: 'Memuat sesi refleksi...'),
            );
          }
          if (snapshot.hasError) {
            return ErrorStateWidget(
              message: 'Gagal memuat sesi refleksi',
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _sessionFuture = _loadSession();
                });
              },
            );
          }
          final cards = snapshot.data ?? [];
          if (cards.isEmpty) {
            return const Center(
              child: Text('Tidak ada pertanyaan yang tersedia.'),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final cardData = cards[index];
                  if (cardData is ValueDilemma) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: ValueDilemmaCard(
                        dilemma: cardData,
                        index: index,
                        total: cards.length,
                        onSelected: (option, valueTag) => _handleBinaryAnswer(
                          cardData,
                          option,
                          valueTag,
                          cards.length,
                        ),
                      ),
                    );
                  } else if (cardData is OpenValueQuestion) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: ValueOpenQuestionCard(
                        question: cardData,
                        index: index,
                        total: cards.length,
                        onSubmitted: (text) =>
                            _handleOpenAnswer(cardData, text, cards.length),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              // Navigation buttons
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (_currentIndex > 0)
                        FloatingActionButton.small(
                          heroTag: 'prev_btn',
                          onPressed: _isSaving
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                          child: const Icon(Icons.arrow_back),
                        )
                      else
                        const SizedBox(width: 48),
                      // Progress indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${cards.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Next button (disabled, use swipe or answer)
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              if (_isSaving)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: Center(
                    child: LoadingStateWidget(message: 'Menyimpan jawaban...'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
