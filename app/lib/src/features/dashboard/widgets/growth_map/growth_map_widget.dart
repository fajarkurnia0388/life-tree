import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/app_constants.dart';
import '../../dashboard_provider.dart';
import '../../growth_map_provider.dart';
import '../../../habit/services/habit_log_service.dart';
import '../domain_insight_dialog.dart';
import 'growth_map_node.dart';
import 'growth_map_layout.dart';
import 'growth_map_painter.dart';
import 'growth_map_semantics.dart';

class GrowthMapWidget extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Color? activeDomainColor;

  const GrowthMapWidget({
    super.key,
    required this.width,
    required this.height,
    this.activeDomainColor,
  });

  @override
  ConsumerState<GrowthMapWidget> createState() => _GrowthMapWidgetState();
}

class _GrowthMapWidgetState extends ConsumerState<GrowthMapWidget> {
  bool _isToggling = false;

  Future<void> _toggleHabit(
    BuildContext context,
    dynamic habit,
    dynamic log,
  ) async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    // Capture messenger before any async gap to satisfy use_build_context_synchronously.
    final messenger = ScaffoldMessenger.of(context);

    try {
      final service = ref.read(habitLogServiceProvider);
      final now = DateTime.now();

      if (log != null && log.status == HabitStatus.done) {
        await service.markUnchecked(habit: habit, log: log);
      } else {
        await service.markDone(habit: habit, date: now);
      }
      ref.invalidate(dashboardDataProvider);
      ref.invalidate(growthMapProvider);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status kebiasaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isToggling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final growthMapAsync = ref.watch(growthMapProvider);

    return growthMapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Gagal memuat peta pertumbuhan: $err')),
      data: (viewModel) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth > 0
                ? constraints.maxWidth
                : widget.width;
            final h = constraints.maxHeight > 0
                ? constraints.maxHeight
                : widget.height;

            // Generate "+" empty placeholder leaf nodes for domains with no habits today
            final List<LeafNode> extendedLeaves = List.from(viewModel.leaves);
            final domainOrder = [
              'Tubuh',
              'Keuangan',
              'Hubungan',
              'Emosi',
              'Karir',
              'Rekreasi',
            ];

            for (final domain in domainOrder) {
              final domainLeaves = extendedLeaves.where(
                (l) => l.domainTag == domain,
              );
              if (domainLeaves.isEmpty) {
                extendedLeaves.add(
                  LeafNode(
                    id: 'placeholder-$domain',
                    label: 'Tambah Kebiasaan',
                    domainTag: domain,
                    isDone: false,
                    initial: '+',
                    originalHabit: null,
                    semanticLabel:
                        'Dahan $domain belum memiliki kebiasaan hari ini. Ketuk untuk menambah.',
                  ),
                );
              }
            }

            // Calculate Coordinates
            final positionedNodes = GrowthMapLayout.calculate(
              width: w,
              height: h,
              root: viewModel.root,
              branches: viewModel.branches,
              leaves: extendedLeaves,
              flowers: viewModel.flowers,
              fruits: viewModel.fruits,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Connection lines painted in background
                Positioned.fill(
                  child: CustomPaint(
                    painter: GrowthMapPainter(
                      nodes: positionedNodes,
                      season: viewModel.season,
                    ),
                  ),
                ),

                // 2. Interactive Nodes Overlay
                ...positionedNodes.map((node) {
                  final offset = node.position;
                  final String semanticLabel = GrowthMapSemantics.buildLabel(
                    node,
                  );

                  if (node is RootNode) {
                    return Positioned(
                      left: offset.dx - 22,
                      top: offset.dy - 22,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Kompas Nilai Inti 🧭'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: node.coreValues.isEmpty
                                        ? [
                                            const Text(
                                              'Belum ada nilai terpilih. Silakan atur di Tab Profil.',
                                            ),
                                          ]
                                        : node.coreValues
                                              .map(
                                                (v) => ListTile(
                                                  leading: const Icon(
                                                    Icons.star_rounded,
                                                    color: Colors.amber,
                                                  ),
                                                  title: Text(v),
                                                ),
                                              )
                                              .toList(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                node.icon,
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (node is BranchNode) {
                    // Glow color depends on branch health
                    final isDeficit = node.score < 5.0;
                    final glowColor = isDeficit
                        ? Colors.amber[800]!
                        : node.color;
                    final isHealthy = node.score >= 8.0;

                    return Positioned(
                      left: offset.dx - 18,
                      top: offset.dy - 18,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => DomainInsightDialog(
                                  domain: node.id,
                                  score: node.score,
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: glowColor,
                                  width: isHealthy ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: glowColor.withValues(
                                      alpha: isHealthy ? 0.35 : 0.15,
                                    ),
                                    blurRadius: isHealthy ? 10 : 5,
                                    spreadRadius: isHealthy ? 3 : 1,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(node.icon, size: 18, color: glowColor),
                                  if (isDeficit)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.amber,
                                        ),
                                        child: const Icon(
                                          Icons.priority_high_rounded,
                                          size: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (node is LeafNode) {
                    final isPlaceholder = node.originalHabit == null;

                    return Positioned(
                      left: offset.dx - 11,
                      top: offset.dy - 11,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isPlaceholder) {
                                context.push('/add-habit');
                              } else {
                                _toggleHabit(
                                  context,
                                  node.originalHabit,
                                  node.originalLog,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: node.isDone
                                    ? Colors.teal
                                    : (isPlaceholder
                                          ? theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5)
                                          : theme.colorScheme.surface),
                                border: Border.all(
                                  color: node.isDone
                                      ? Colors.teal
                                      : (isPlaceholder
                                            ? theme.colorScheme.outline
                                                  .withValues(alpha: 0.3)
                                            : theme.colorScheme.outline),
                                  width: 1.0,
                                ),
                                boxShadow: node.isDone
                                    ? [
                                        BoxShadow(
                                          color: Colors.teal.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  node.initial,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: node.isDone
                                        ? Colors.white
                                        : (isPlaceholder
                                              ? theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.4)
                                              : theme.colorScheme.onSurface),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (node is FruitNode) {
                    return Positioned(
                      left: offset.dx - 11,
                      top: offset.dy - 11,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Keputusan Penting: ${node.label}',
                                  ),
                                  content: Text(
                                    'Domain: ${node.domainTag}\n\nKeputusan ini dicatat sebagai milestone penting dalam perjalanan pertumbuhanmu.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                node.icon,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
                if (_isToggling)
                  Positioned.fill(
                    child: Container(
                      color: Colors.transparent,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
