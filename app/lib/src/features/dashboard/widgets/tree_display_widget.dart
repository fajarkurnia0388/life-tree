import 'package:flutter/material.dart';
import '../../../core/domain/tree_skin_config.dart';
import '../../../core/theme/theme.dart';

/// Displays the tree illustration for a given skin and growth stage.
/// Shows a PNG illustration asset with animated crossfade transitions between stages.
class TreeDisplayWidget extends StatelessWidget {
  final String skinId;
  final int cumulativeDays;
  final String season;
  final double size;

  const TreeDisplayWidget({
    super.key,
    required this.skinId,
    required this.cumulativeDays,
    required this.season,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final stage = TreeSkinConfig.getStage(cumulativeDays, season);
    final assetPath = TreeSkinConfig.getAssetPath(skinId, stage);
    final isRecovery = season == 'Recovery';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Stack(
        key: ValueKey('$skinId-$stage'),
        alignment: Alignment.center,
        children: [
          // Tree illustration
          Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) {
              // Graceful fallback if asset is missing
              return _buildFallbackEmoji(stage, skinId, size);
            },
          ),
          // Snow overlay for Recovery mode
          if (isRecovery)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SnowflakePainter(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackEmoji(String stage, String skin, double size) {
    final emoji = _fallbackEmoji(stage, skin);
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }

  String _fallbackEmoji(String stage, String skin) {
    if (stage == TreeSkinConfig.stageRecovery) {
      return skin == 'Sakura' ? '❄️🌸' : skin == 'Maple' ? '❄️🍁' : skin == 'Bonsai' ? '❄️🪴' : '❄️🌳';
    }
    if (stage == TreeSkinConfig.stageSeed) return '🌰';
    if (stage == TreeSkinConfig.stageSprout) return '🌱';
    if (stage == TreeSkinConfig.stageSapling) return '🌿';
    if (stage == TreeSkinConfig.stageBlooming) {
      return skin == 'Sakura' ? '🌸🌳' : skin == 'Maple' ? '🍁🌳' : skin == 'Bonsai' ? '🪴' : '🌳';
    }
    return skin == 'Sakura' ? '🌸🌲' : skin == 'Maple' ? '🍁🌲' : skin == 'Bonsai' ? '🪴' : '🌲';
  }
}

/// A card widget wrapping the tree display with progress bar and stage label.
class TreeVitalityCard extends StatelessWidget {
  final String skinId;
  final int cumulativeDays;
  final String season;
  final VoidCallback onSkinShopTap;

  const TreeVitalityCard({
    super.key,
    required this.skinId,
    required this.cumulativeDays,
    required this.season,
    required this.onSkinShopTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = TreeSkinConfig.getStage(cumulativeDays, season);
    final label = TreeSkinConfig.getStageLabel(cumulativeDays, season);
    final progress = TreeSkinConfig.getProgress(cumulativeDays, season);
    final isRecovery = season == 'Recovery';
    final progressColor = isRecovery ? CalmTheme.secondaryBlue : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                // Tree illustration
                TreeDisplayWidget(
                  skinId: skinId,
                  cumulativeDays: cumulativeDays,
                  season: season,
                  size: 120,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kesehatan & Pertumbuhan Pohon',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          // Skin Shop button
                          InkWell(
                            onTap: onSkinShopTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.palette_outlined, size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Skin',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(label, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '$cumulativeDays Hari Keberhasilan Kumulatif',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Stage badge chip
                      _StageBadge(stage: stage, isRecovery: isRecovery),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: progressColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill badge showing the current growth stage name.
class _StageBadge extends StatelessWidget {
  final String stage;
  final bool isRecovery;
  const _StageBadge({required this.stage, required this.isRecovery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isRecovery ? CalmTheme.secondaryBlue : theme.colorScheme.primary;
    final label = switch (stage) {
      TreeSkinConfig.stageSeed     => 'Benih',
      TreeSkinConfig.stageSprout   => 'Tunas',
      TreeSkinConfig.stageSapling  => 'Batang Muda',
      TreeSkinConfig.stageBlooming => 'Mekar',
      TreeSkinConfig.stageMature   => 'Dewasa',
      TreeSkinConfig.stageRecovery => 'Istirahat',
      _                            => stage,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// Subtle snowflake overlay painter for Recovery mode.
class _SnowflakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x557CB9E8)
      ..style = PaintingStyle.fill;
    
    // Draw a few simple snowflake dots
    final positions = [
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.08),
      Offset(size.width * 0.85, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.7),
    ];
    for (final pos in positions) {
      canvas.drawCircle(pos, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
