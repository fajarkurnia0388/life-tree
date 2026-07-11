import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/domain/app_constants.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/theme/theme.dart';
import '../../../cultivation/cultivation_provider.dart';
import '../../../cultivation/cultivation_strings.dart';
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
  final String? selectedDomain;
  final void Function(String domain)? onDomainTap;

  const GrowthMapWidget({
    super.key,
    required this.width,
    required this.height,
    this.activeDomainColor,
    this.selectedDomain,
    this.onDomainTap,
  });

  @override
  ConsumerState<GrowthMapWidget> createState() => _GrowthMapWidgetState();
}

class _MorphingGrowthMapLines extends StatefulWidget {
  final List<GrowthMapNode> nodes;
  final String season;

  const _MorphingGrowthMapLines({required this.nodes, required this.season});

  @override
  State<_MorphingGrowthMapLines> createState() =>
      _MorphingGrowthMapLinesState();
}

class _MorphingGrowthMapLinesState extends State<_MorphingGrowthMapLines>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<GrowthMapNode> _fromNodes;
  late List<GrowthMapNode> _toNodes;

  @override
  void initState() {
    super.initState();
    _fromNodes = widget.nodes;
    _toNodes = widget.nodes;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant _MorphingGrowthMapLines oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        _signature(oldWidget.nodes, oldWidget.season) !=
        _signature(widget.nodes, widget.season);
    if (!changed) return;

    _fromNodes = _interpolatedNodes(_fromNodes, _toNodes, _controller.value);
    _toNodes = widget.nodes;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _signature(List<GrowthMapNode> nodes, String season) {
    return '$season|${nodes.map((node) => '${node.type}:${node.id}:${node.position.dx.toStringAsFixed(1)},${node.position.dy.toStringAsFixed(1)}').join(';')}';
  }

  List<GrowthMapNode> _interpolatedNodes(
    List<GrowthMapNode> from,
    List<GrowthMapNode> to,
    double rawT,
  ) {
    final t = Curves.easeInOutCubic.transform(rawT.clamp(0.0, 1.0).toDouble());
    final fromById = <String, GrowthMapNode>{
      for (final node in from) '${node.type}:${node.id}': node,
    };

    // Draw only the target node set. This prevents old focused/off-screen
    // connector snapshots from lingering as ghost lines after a morph.
    return to.map((target) {
      final previous = fromById['${target.type}:${target.id}'];
      if (previous == null) return target;
      return target.copyWith(
        position: Offset.lerp(previous.position, target.position, t),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final nodes = _interpolatedNodes(
          _fromNodes,
          _toNodes,
          _controller.value,
        );
        return CustomPaint(
          painter: GrowthMapPainter(nodes: nodes, season: widget.season),
        );
      },
    );
  }
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

  void _showLockedStreamSnackBar(BuildContext context, BranchNode node) {
    final messenger = ScaffoldMessenger.of(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final domainParam = Uri.encodeComponent(node.id);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CalmTheme.daoSurface,
        elevation: 0,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 92 + safeBottom),
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        duration: const Duration(milliseconds: 4800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: CalmTheme.daoJade.withValues(alpha: 0.38),
            width: 1,
          ),
        ),
        showCloseIcon: true,
        closeIconColor: CalmTheme.daoMuted,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CalmTheme.obsidian.withValues(alpha: 0.72),
                border: Border.all(
                  color: CalmTheme.daoGold.withValues(alpha: 0.45),
                ),
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: CalmTheme.daoGold,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${node.label} Stream belum aktif',
                    style: const TextStyle(
                      color: CalmTheme.daoCream,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tambahkan practice untuk mulai membuka stream ini. Developer Mode membuka semua stream untuk testing.',
                    style: TextStyle(
                      color: CalmTheme.daoMuted,
                      height: 1.35,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Tambah Practice',
          textColor: CalmTheme.daoGold,
          onPressed: () => context.push('/add-habit?domain=$domainParam'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);
    final growthMapAsync = ref.watch(growthMapProvider);

    return growthMapAsync.when(
      loading: () => const LoadingStateWidget(message: 'Memuat peta pertumbuhan...'),
      error: (err, stack) => ErrorStateWidget(
        message: 'Gagal memuat peta pertumbuhan',
        error: err.toString(),
        onRetry: () {
          ref.invalidate(growthMapProvider);
        },
      ),
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
            final activeDomain = widget.selectedDomain;

            // Do not display placeholder "+" nodes in the full domain view.
            // Keep only real habit nodes for a cleaner growth map.

            // Calculate Coordinates
            final positionedNodes = GrowthMapLayout.calculate(
              width: w,
              height: h,
              root: viewModel.root,
              branches: activeDomain == null
                  ? viewModel.branches
                  : viewModel.branches
                        .where((b) => b.id == activeDomain)
                        .toList(),
              leaves: activeDomain == null
                  ? extendedLeaves
                  : extendedLeaves
                        .where((l) => l.domainTag == activeDomain)
                        .toList(),
              flowers: activeDomain == null
                  ? viewModel.flowers
                  : viewModel.flowers
                        .where((f) => f.domainTag == activeDomain)
                        .toList(),
              fruits: activeDomain == null
                  ? viewModel.fruits
                  : viewModel.fruits
                        .where((f) => f.domainTag == activeDomain)
                        .toList(),
              selectedDomain: activeDomain,
            );

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Connection lines painted in background.
                // Keep this as a single current-state painter (no cross-fading
                // old line layers). Cross-fading line snapshots can leave
                // off-screen ghost connectors during PPT-like morph transitions.
                Positioned.fill(
                  child: ClipRect(
                    child: _MorphingGrowthMapLines(
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
                    languageLevel,
                  );

                  if (node is RootNode) {
                    final rootDiameter = widget.selectedDomain != null
                        ? 46.0
                        : 44.0;
                    final iconSize = widget.selectedDomain != null
                        ? 22.0
                        : 24.0;
                    return AnimatedPositioned(
                      key: ValueKey('root-${node.id}'),
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.easeOutCubic,
                      left: offset.dx - rootDiameter / 2,
                      top: offset.dy - rootDiameter / 2,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final rootLabel =
                                  CultivationStrings.growthMapRoot(
                                    languageLevel,
                                  );
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('$rootLabel 🧭'),
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
                              width: rootDiameter,
                              height: rootDiameter,
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
                                size: iconSize,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (node is BranchNode) {
                    final isSelectedBranch =
                        widget.selectedDomain != null &&
                        node.id == widget.selectedDomain;
                    final branchDiameter = isSelectedBranch ? 46.0 : 36.0;
                    final iconSize = isSelectedBranch ? 22.0 : 18.0;
                    final isDeficit = !node.isLocked && node.score < 5.0;
                    final glowColor = node.isLocked
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : (isDeficit ? Colors.amber[800]! : node.color);
                    final isHealthy = !node.isLocked && node.score >= 8.0;

                    return AnimatedPositioned(
                      key: ValueKey('branch-${node.id}'),
                      duration: const Duration(milliseconds: 560),
                      curve: Curves.easeOutCubic,
                      left: offset.dx - branchDiameter / 2,
                      top: offset.dy - branchDiameter / 2,
                      child: Semantics(
                        label: semanticLabel,
                        button: true,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: node.isLocked
                                ? () => _showLockedStreamSnackBar(context, node)
                                : widget.onDomainTap != null
                                ? () => widget.onDomainTap!(node.id)
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => DomainInsightDialog(
                                        domain: node.id,
                                        score: node.score,
                                      ),
                                    );
                                  },
                            borderRadius: BorderRadius.circular(18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: branchDiameter,
                                  height: branchDiameter,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: node.isLocked
                                        ? theme.colorScheme.surface.withValues(
                                            alpha: 0.62,
                                          )
                                        : theme.colorScheme.surface,
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
                                      Icon(
                                        node.icon,
                                        size: iconSize,
                                        color: glowColor,
                                      ),
                                      if (node.isLocked)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: theme.colorScheme.surface,
                                              border: Border.all(
                                                color: glowColor,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.lock_rounded,
                                              size: 9,
                                              color: glowColor,
                                            ),
                                          ),
                                        ),
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
                                // Keep the focused map visually clean. The old
                                // visible "Lihat kebiasaan" chip often collided
                                // with the root/placeholder nodes on compact
                                // mobile widths; the node remains tappable and
                                // accessible through Semantics.
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (node is LeafNode) {
                    final isPlaceholder = node.originalHabit == null;

                    return AnimatedPositioned(
                      key: ValueKey('leaf-${node.id}'),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
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
                    return AnimatedPositioned(
                      key: ValueKey('fruit-${node.id}'),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
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
                      child: const Center(
                        child: LoadingStateWidget(
                          message: 'Memperbarui status kebiasaan...',
                        ),
                      ),
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
