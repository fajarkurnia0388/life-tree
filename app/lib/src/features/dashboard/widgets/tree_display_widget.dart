import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/domain/tree_skin_config.dart';
import '../../../core/theme/theme.dart';
import 'growth_map/growth_map_widget.dart';

/// Displays the conceptual tree view for a given skin and growth stage.
/// Renders the growth state through a conceptual map rather than static image assets.
class TreeDisplayWidget extends StatelessWidget {
  final String skinId;
  final int cumulativeDays;
  final String season;
  final double width;
  final double height;
  final Color? activeDomainColor;

  const TreeDisplayWidget({
    super.key,
    required this.skinId,
    required this.cumulativeDays,
    required this.season,
    this.width = double.infinity,
    this.height = 220,
    this.activeDomainColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRecovery = season == Season.recovery;

    // ── Wrap everything in a rounded clip ──
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            // ── Neutral canvas for the conceptual tree view ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.18),
                ),
              ),
            ),

            // ── Dynamic Domain Aura ──
            if (activeDomainColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.2),
                      radius: 0.65,
                      colors: [
                        activeDomainColor!.withValues(alpha: 0.32),
                        activeDomainColor!.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Growth Map (Iterasi 2) ──
            Positioned.fill(
              child: GrowthMapWidget(
                width: width,
                height: height,
                activeDomainColor: activeDomainColor,
              ),
            ),

            // ── Snow overlay (Recovery mode) ──
            if (isRecovery)
              const Positioned.fill(
                child: IgnorePointer(child: SnowOverlayWidget()),
              ),
          ],
        ),
      ),
    );
  }
}

/// A card widget wrapping the tree display with progress bar and stage label.
class TreeVitalityCard extends StatefulWidget {
  final String skinId;
  final int cumulativeDays;
  final String season;
  final VoidCallback onSkinShopTap;
  final Color? activeDomainColor;

  const TreeVitalityCard({
    super.key,
    required this.skinId,
    required this.cumulativeDays,
    required this.season,
    required this.onSkinShopTap,
    this.activeDomainColor,
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
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
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

      final fileName =
          'lifetree_${widget.skinId}_${widget.cumulativeDays}d_${DateTime.now().millisecondsSinceEpoch}.png';

      // 1. Always save to temp directory so it can be shared reliably on mobile/web
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // 2. On desktop platforms, also try saving to Downloads directory for easy user access
      Directory? downloadsDir;
      File? downloadsFile;
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        color: theme.colorScheme.primary,
                      ),
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
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
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
                            await SharePlus.instance.share(
                              ShareParams(
                                files: [
                                  XFile(tempFile.path, mimeType: 'image/png'),
                                ],
                                text:
                                    'Lihat keindahan pohon LifeTree saya! 🌲✨ Hari ke-${widget.cumulativeDays} (${widget.skinId}). #LifeTree',
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan / Simpan Foto'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                              final uri = Uri.file(downloadsDir.path);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(
                              Icons.folder_open_rounded,
                              size: 18,
                            ),
                            label: const Text('Buka Folder Downloads'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
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
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
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
    final label = TreeSkinConfig.getStageLabel(
      widget.cumulativeDays,
      widget.season,
    );
    final normalizedSkinId = TreeSkinConfig.normalizeSkinId(widget.skinId);
    final progress = TreeSkinConfig.getProgress(
      widget.cumulativeDays,
      widget.season,
    );
    final isRecovery = widget.season == Season.recovery;
    final progressColor = isRecovery
        ? CalmTheme.secondaryBlue
        : theme.colorScheme.primary;

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
                    activeDomainColor: widget.activeDomainColor,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_outlined,
                                      size: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Skin Shop button
                InkWell(
                  onTap: widget.onSkinShopTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Skin: $normalizedSkinId',
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
    final color = isRecovery
        ? CalmTheme.secondaryBlue
        : theme.colorScheme.primary;
    final label = switch (stage) {
      TreeSkinConfig.stageSeed => 'Benih',
      TreeSkinConfig.stageSprout => 'Tunas',
      TreeSkinConfig.stageSeedling => 'Bibit',
      TreeSkinConfig.stageSapling => 'Batang Muda',
      TreeSkinConfig.stageYoung => 'Pohon Muda',
      TreeSkinConfig.stageGrowing => 'Tumbuh',
      TreeSkinConfig.stageEstablished => 'Mantap',
      TreeSkinConfig.stageBlooming => 'Rimbun',
      TreeSkinConfig.stageFlourishing => 'Subur',
      TreeSkinConfig.stageMature => 'Dewasa',
      TreeSkinConfig.stageRecovery => 'Istirahat',
      _ => stage,
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
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Stateful widget for animated falling snow in Recovery mode.
class SnowOverlayWidget extends StatefulWidget {
  const SnowOverlayWidget({super.key});

  @override
  State<SnowOverlayWidget> createState() => _SnowOverlayWidgetState();
}

class _SnowOverlayWidgetState extends State<SnowOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Snowflake> _snowflakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize 35 snowflakes with random distributions
    final random = math.Random(42);
    _snowflakes = List.generate(35, (index) {
      return _Snowflake(
        xRatio: random.nextDouble(),
        yRatio: random.nextDouble(),
        speed: 0.05 + random.nextDouble() * 0.1,
        swaySpeed: 0.5 + random.nextDouble() * 1.5,
        swayAmplitude: 0.01 + random.nextDouble() * 0.02,
        radius: 1.5 + random.nextDouble() * 2.5,
        opacity: 0.3 + random.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedSnowPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Snowflake {
  final double xRatio;
  final double yRatio;
  final double speed;
  final double swaySpeed;
  final double swayAmplitude;
  final double radius;
  final double opacity;

  _Snowflake({
    required this.xRatio,
    required this.yRatio,
    required this.speed,
    required this.swaySpeed,
    required this.swayAmplitude,
    required this.radius,
    required this.opacity,
  });
}

class _AnimatedSnowPainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  final double progress;

  _AnimatedSnowPainter({required this.snowflakes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in snowflakes) {
      // Calculate current falling y position
      double y = (flake.yRatio + progress * flake.speed * 10) % 1.0;
      y *= size.height;

      // Calculate horizontal sway using sine wave
      final swayAngle = progress * 2 * math.pi * flake.swaySpeed;
      final sway = math.sin(swayAngle) * flake.swayAmplitude * size.width;
      double x = (flake.xRatio * size.width + sway) % size.width;

      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(x, y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedSnowPainter oldDelegate) => true;
}
