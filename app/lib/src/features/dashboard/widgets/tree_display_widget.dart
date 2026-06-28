import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/domain/tree_skin_config.dart';
import '../../../core/theme/theme.dart';
import '../dashboard_provider.dart';
import 'tree_painter.dart';

/// Displays the tree illustration for a given skin and growth stage.
/// Shows a PNG illustration asset with animated crossfade transitions between stages.
class TreeDisplayWidget extends ConsumerWidget {
  final String skinId;
  final int cumulativeDays;
  final String season;
  final double width;
  final double height;

  const TreeDisplayWidget({
    super.key,
    required this.skinId,
    required this.cumulativeDays,
    required this.season,
    this.width = double.infinity,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = TreeSkinConfig.getStage(cumulativeDays, season);
    final assetPath = TreeSkinConfig.getAssetPath(skinId, stage);
    final isRecovery = season == 'Recovery';

    // 1. Determine celestial time of day (Auto or Overridden)
    final timeOverride = ref.watch(devTimeOfDayOverrideProvider);
    final CelestialTime activeTime;
    if (timeOverride != CelestialTime.auto) {
      activeTime = timeOverride;
    } else {
      final hour = DateTime.now().hour;
      if (hour >= 6 && hour < 11) {
        activeTime = CelestialTime.morning;
      } else if (hour >= 11 && hour < 15) {
        activeTime = CelestialTime.noon;
      } else if (hour >= 15 && hour < 18) {
        activeTime = CelestialTime.sunset;
      } else {
        activeTime = CelestialTime.night;
      }
    }

    // 2. Map sky gradient colors (top → horizon)
    final List<Color> skyColors = switch (activeTime) {
      CelestialTime.morning => const [Color(0xFF89CFF0), Color(0xFFFFF3E0)], // Light blue → warm yellow horizon
      CelestialTime.noon    => const [Color(0xFF1565C0), Color(0xFF4FC3F7)], // Deep blue → light blue
      CelestialTime.sunset  => const [Color(0xFF4A148C), Color(0xFFFF7043)], // Purple → fiery orange horizon
      CelestialTime.night   => const [Color(0xFF0D1B2A), Color(0xFF1B2838)], // Dark navy → deep indigo
      _                     => const [Color(0xFF1565C0), Color(0xFF4FC3F7)],
    };

    // 3. Map ground colors per time of day
    final List<Color> groundColors = switch (activeTime) {
      CelestialTime.morning => const [Color(0xFF4CAF50), Color(0xFF388E3C)], // Fresh morning green
      CelestialTime.noon    => const [Color(0xFF66BB6A), Color(0xFF43A047)], // Bright noon green
      CelestialTime.sunset  => const [Color(0xFF8D6E63), Color(0xFF6D4C41)], // Warm brown earth at dusk
      CelestialTime.night   => const [Color(0xFF1A3327), Color(0xFF0F2319)], // Dark night earth
      _                     => const [Color(0xFF66BB6A), Color(0xFF43A047)],
    };

    const double groundRatio = 0.22; // 22% of height is ground strip
    final double treeSize = height * 0.80;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: ClipRRect(
        key: ValueKey('$skinId-$stage-$activeTime'),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.bottomCenter,
            children: [
              // ── Sky background (full rectangle) ──
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.75],
                      colors: skyColors,
                    ),
                  ),
                ),
              ),

              // ── Night stars (drawn over entire sky) ──
              if (activeTime == CelestialTime.night)
                Positioned.fill(
                  child: CustomPaint(painter: _StarsPainter()),
                ),

              // ── Sun / Moon celestial body ──
              ..._buildCelestialBody(activeTime, width, height),

              // ── Ground strip (bottom 22%) ──
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: height * groundRatio,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: groundColors,
                    ),
                  ),
                ),
              ),

              // ── Ground edge fade: thin darker strip at the top of ground ──
              Positioned(
                left: 0,
                right: 0,
                bottom: height * groundRatio - 4,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.22),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Tree (realistic PNG asset; falls back to procedural painter
              //    if the asset for this stage hasn't been added yet) ──
              Positioned(
                bottom: height * 0.04,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: treeSize,
                    height: treeSize,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        // Asset missing → render the procedural tree instead so
                        // the user always sees *something* sensible.
                        return CustomPaint(
                          painter: OrganicTreePainter(
                            days: cumulativeDays.toDouble(),
                            skinId: skinId,
                            isRecovery: isRecovery,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Snow overlay (Recovery mode) ──
              if (isRecovery)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _SnowflakePainter()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCelestialBody(CelestialTime time, double w, double h) {
    final double sunMoonSize = h * 0.14; // proportional to panorama height
    switch (time) {
      case CelestialTime.morning:
        // Rising sun on the right, mid-low sky
        return [
          Positioned(
            top: h * 0.18,
            right: w * 0.12,
            child: Container(
              width: sunMoonSize,
              height: sunMoonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCC02),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.5),
                    blurRadius: 18,
                    spreadRadius: 4,
                  )
                ],
              ),
            ),
          ),
        ];

      case CelestialTime.noon:
        // High sun centered-right
        return [
          Positioned(
            top: h * 0.06,
            right: w * 0.18,
            child: Container(
              width: sunMoonSize * 1.1,
              height: sunMoonSize * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFDD835),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.55),
                    blurRadius: 22,
                    spreadRadius: 6,
                  )
                ],
              ),
            ),
          ),
        ];

      case CelestialTime.sunset:
        // Large sun touching horizon, left side
        return [
          Positioned(
            bottom: h * 0.20,
            left: w * 0.10,
            child: Container(
              width: sunMoonSize * 1.3,
              height: sunMoonSize * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6F00),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 5,
                  )
                ],
              ),
            ),
          ),
        ];

      case CelestialTime.night:
        // Crescent moon — top right
        return [
          Positioned(
            top: h * 0.08,
            right: w * 0.10,
            child: SizedBox(
              width: sunMoonSize * 1.2,
              height: sunMoonSize * 1.2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Full moon disk
                  Container(
                    width: sunMoonSize * 1.2,
                    height: sunMoonSize * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFF9C4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  // Mask circle: creates crescent cutout
                  Positioned(
                    top: -sunMoonSize * 0.18,
                    left: sunMoonSize * 0.30,
                    child: Container(
                      width: sunMoonSize * 1.2,
                      height: sunMoonSize * 1.2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

      default:
        return [];
    }
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
    switch (stage) {
      case TreeSkinConfig.stageSeed:
        return '🌰';
      case TreeSkinConfig.stageSprout:
      case TreeSkinConfig.stageSeedling:
        return '🌱';
      case TreeSkinConfig.stageSapling:
      case TreeSkinConfig.stageYoung:
        return '🌿';
      case TreeSkinConfig.stageGrowing:
      case TreeSkinConfig.stageEstablished:
        return skin == 'Sakura' ? '🌸🌳' : skin == 'Maple' ? '🍁🌳' : skin == 'Bonsai' ? '🪴' : '🌳';
      case TreeSkinConfig.stageBlooming:
      case TreeSkinConfig.stageFlourishing:
        return skin == 'Sakura' ? '🌸🌳' : skin == 'Maple' ? '🍁🌳' : skin == 'Bonsai' ? '🪴' : '🌳';
    }
    return skin == 'Sakura' ? '🌸🌲' : skin == 'Maple' ? '🍁🌲' : skin == 'Bonsai' ? '🪴' : '🌲';
  }
}

/// A card widget wrapping the tree display with progress bar and stage label.
class TreeVitalityCard extends StatefulWidget {
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
  State<TreeVitalityCard> createState() => _TreeVitalityCardState();
}

class _TreeVitalityCardState extends State<TreeVitalityCard> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _captureAndShareTree() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
    });

    try {
      // Find boundary render object
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary render object not ready');
      }

      // Convert to image with high 3.0x resolution for crisp detail!
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to obtain PNG byte data');
      }
      final pngBytes = byteData.buffer.asUint8List();

      final fileName = 'lifetree_${widget.skinId}_${widget.cumulativeDays}d_${DateTime.now().millisecondsSinceEpoch}.png';

      // 1. Always save to temp directory so it can be shared reliably on mobile/web
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // 2. On desktop platforms, also try saving to Downloads directory for easy user access
      Directory? downloadsDir;
      File? downloadsFile;
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        try {
          downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            downloadsFile = File('${downloadsDir.path}/$fileName');
            await downloadsFile.writeAsBytes(pngBytes);
          }
        } catch (_) {}
      }

      if (mounted) {
        _showCaptureSuccessDialog(
          context,
          pngBytes,
          tempFile,
          fileName,
          downloadsDir,
          downloadsFile,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showCaptureSuccessDialog(
    BuildContext context,
    Uint8List pngBytes,
    File tempFile,
    String fileName,
    Directory? downloadsDir,
    File? downloadsFile,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Foto Pohon Berhasil Diambil!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image Preview
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1.6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Image.memory(pngBytes, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      if (downloadsFile != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Tersimpan di: Downloads/$fileName',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await Share.shareXFiles(
                              [XFile(tempFile.path, mimeType: 'image/png')],
                              text: 'Lihat keindahan pohon LifeTree saya! 🌲✨ Hari ke-${widget.cumulativeDays} (${widget.skinId}). #LifeTree',
                            );
                          },
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan / Simpan Foto'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Open Folder Button (Desktop only)
                      if (downloadsDir != null) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.file(downloadsDir!.path);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.folder_open_rounded, size: 18),
                            label: const Text('Buka Folder Downloads'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Close button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = TreeSkinConfig.getStage(widget.cumulativeDays, widget.season);
    final label = TreeSkinConfig.getStageLabel(widget.cumulativeDays, widget.season);
    final progress = TreeSkinConfig.getProgress(widget.cumulativeDays, widget.season);
    final isRecovery = widget.season == 'Recovery';
    final progressColor = isRecovery ? CalmTheme.secondaryBlue : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Full-width Panorama Tree Scene wrapped in RepaintBoundary for capture feature
            Stack(
              children: [
                RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: TreeDisplayWidget(
                    skinId: widget.skinId,
                    cumulativeDays: widget.cumulativeDays,
                    season: widget.season,
                    width: double.infinity,
                    height: 220,
                  ),
                ),
                // Floating minimal capture button at top-right (outside RepaintBoundary so it's not captured)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Tooltip(
                    message: 'Ambil Foto Pohon',
                    child: ClipOval(
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.12),
                        child: InkWell(
                          onTap: _isCapturing ? null : _captureAndShareTree,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: _isCapturing
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_outlined,
                                      size: 16,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Section (Title & Skin button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kesehatan & Pertumbuhan Pohon',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Skin Shop button
                InkWell(
                  onTap: widget.onSkinShopTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Skin Shop',
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
            const SizedBox(height: 12),

            // Stats & Badge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.cumulativeDays} Hari Keberhasilan Kumulatif',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                _StageBadge(stage: stage, isRecovery: isRecovery),
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
      TreeSkinConfig.stageSeed        => 'Benih',
      TreeSkinConfig.stageSprout      => 'Tunas',
      TreeSkinConfig.stageSeedling    => 'Bibit',
      TreeSkinConfig.stageSapling     => 'Batang Muda',
      TreeSkinConfig.stageYoung       => 'Pohon Muda',
      TreeSkinConfig.stageGrowing     => 'Tumbuh',
      TreeSkinConfig.stageEstablished => 'Mantap',
      TreeSkinConfig.stageBlooming    => 'Rimbun',
      TreeSkinConfig.stageFlourishing => 'Subur',
      TreeSkinConfig.stageMature      => 'Dewasa',
      TreeSkinConfig.stageRecovery    => 'Istirahat',
      _                               => stage,
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

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;
    
    final starPoints = [
      Offset(size.width * 0.16, size.height * 0.38),
      Offset(size.width * 0.76, size.height * 0.22),
      Offset(size.width * 0.46, size.height * 0.14),
      Offset(size.width * 0.82, size.height * 0.44),
      Offset(size.width * 0.32, size.height * 0.58),
      Offset(size.width * 0.68, size.height * 0.68),
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.86, size.height * 0.16),
    ];
    
    for (final pt in starPoints) {
      canvas.drawCircle(pt, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
