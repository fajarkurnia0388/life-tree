import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/theme/theme.dart';
import '../../cultivation/cultivation_constants.dart';
import '../../cultivation/cultivation_provider.dart';
import '../../cultivation/cultivation_strings.dart';
import 'growth_map/growth_map_widget.dart';

/// Displays the conceptual tree view for the current growth state.
/// Renders the growth state through a conceptual map rather than static image assets.
class TreeDisplayWidget extends StatelessWidget {
  final int cumulativeDays;
  final String season;
  final double width;
  final double height;
  final Color? activeDomainColor;
  final String? selectedDomain;
  final void Function(String domain)? onDomainNavigate;
  final VoidCallback? onDomainReset;
  final CultivationSeason? cultivationSeason;

  const TreeDisplayWidget({
    super.key,
    required this.cumulativeDays,
    required this.season,
    this.width = double.infinity,
    this.height = 220,
    this.activeDomainColor,
    this.selectedDomain,
    this.onDomainNavigate,
    this.onDomainReset,
    this.cultivationSeason,
  });

  @override
  Widget build(BuildContext context) {
    final isRecovery = season == Season.recovery;
    final isDormant = season == Season.dormant;
    final isTribulation = cultivationSeason == CultivationSeason.tribulation;
    final isQuietIntegration =
        cultivationSeason == CultivationSeason.quietIntegration;

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

            // ── Peta Pertumbuhan Konseptual ──
            // AnimatedSwitcher gives the focus/unfocus state a PPT-like
            // transition instead of snapping instantly between layouts.
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                reverseDuration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: GrowthMapWidget(
                  key: ValueKey(selectedDomain ?? 'all-domains'),
                  width: width,
                  height: height,
                  activeDomainColor: activeDomainColor,
                  selectedDomain: selectedDomain,
                  onDomainTap: onDomainNavigate,
                ),
              ),
            ),

            if (selectedDomain != null && onDomainReset != null)
              Positioned(
                top: 0,
                left: 0,
                child: Tooltip(
                  message: 'Tampilkan semua domain',
                  child: ClipOval(
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.12),
                      child: InkWell(
                        onTap: onDomainReset,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
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

            // ── Quiet Integration state: night sky with stars, stable soft glow ──
            if (isQuietIntegration)
              Positioned.fill(
                child: IgnorePointer(child: QuietIntegrationOverlay()),
              ),

            // ── Tribulation state: blue aura with subtle pulse, not harsh/violent ──
            if (isTribulation)
              Positioned.fill(
                child: IgnorePointer(child: TribulationAuraWidget()),
              ),

            // ── Dormant state: dim/restful, never death/decay language ──
            if (isDormant)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Soft recovery veil: gentle rest visual, never death/decay language ──
            if (isRecovery)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CalmTheme.secondaryBlue.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.06),
                          CalmTheme.secondaryBlue.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),
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

/// A card widget wrapping the tree display with progress bar and status label.
class TreeVitalityCard extends ConsumerStatefulWidget {
  final int cumulativeDays;
  final String season;
  final Color? activeDomainColor;
  final String? selectedDomain;
  final void Function(String domain)? onDomainNavigate;
  final VoidCallback? onDomainReset;
  final double? balanceIndex;

  const TreeVitalityCard({
    super.key,
    required this.cumulativeDays,
    required this.season,
    this.activeDomainColor,
    this.selectedDomain,
    this.onDomainNavigate,
    this.onDomainReset,
    this.balanceIndex,
  });

  @override
  ConsumerState<TreeVitalityCard> createState() => _TreeVitalityCardState();
}

class _TreeVitalityCardState extends ConsumerState<TreeVitalityCard> {
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
          'daoji_${widget.cumulativeDays}d_${DateTime.now().millisecondsSinceEpoch}.png';

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
        } catch (e, stackTrace) {
          ErrorHandlerService().logError(
            e,
            stackTrace,
            context: 'TreeDisplayWidget.saveToDownloads',
          );
        }
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
                                    'Lihat keindahan pohon Daoji saya! 🌲✨ Hari ke-${widget.cumulativeDays}. #Daoji',
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
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final cultivation = ref.watch(cultivationProvider).valueOrNull;
    final currentRealm = CultivationConstants.realms.firstWhere(
      (realm) => realm.level == (cultivation?.realm ?? 1),
      orElse: () => CultivationConstants.realms.first,
    );
    final label = DaojiText.resolve(DaojiTextKey.mapTitle, vocabularyLevel);
    final progress = widget.balanceIndex ?? 1.0;
    final isRecovery = widget.season == Season.recovery;
    final progressColor = isRecovery
        ? CalmTheme.secondaryBlue
        : theme.colorScheme.primary;
    final journeyLabel = CultivationStrings.realmDisplay(
      languageLevel,
      currentRealm.indonesianName,
      widget.cumulativeDays,
    );
    final progressLabel = _progressLabel(vocabularyLevel);
    final progressPercent = '${(progress.clamp(0.0, 1.0) * 100).round()}%';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header for the vitality map section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Full-width Panorama Tree Scene wrapped in RepaintBoundary for capture feature
            Stack(
              children: [
                RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: progress >= 0.8 && !isRecovery
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ]
                          : const [],
                    ),
                    child: TreeDisplayWidget(
                      cumulativeDays: widget.cumulativeDays,
                      season: widget.season,
                      width: double.infinity,
                      height: 220,
                      activeDomainColor: widget.activeDomainColor,
                      selectedDomain: widget.selectedDomain,
                      onDomainNavigate: widget.onDomainNavigate,
                      onDomainReset: widget.onDomainReset,
                      cultivationSeason: cultivation?.season,
                    ),
                  ),
                ),
                // Floating minimal capture button at top-right (outside RepaintBoundary so it's not captured)
                Positioned(
                  top: 0,
                  right: 0,
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

            // Current realm + state. Avoid repeating the card title; the
            // visual already communicates the Dao Stream map.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _realmLabel(vocabularyLevel),
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
                        journeyLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (progress >= 0.8 && !isRecovery)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _FullCanopyBadge(languageLevel: languageLevel),
                      ),
                    _StageBadge(
                      isRecovery: isRecovery,
                      languageLevel: languageLevel,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Balance progress. This bar represents the current stream balance,
            // not the realm/day progression, so it has an explicit label.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progressLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                Text(
                  progressPercent,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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

  String _realmLabel(DaojiVocabularyLevel level) {
    return switch (level) {
      DaojiVocabularyLevel.practical => 'Tahap Saat Ini',
      DaojiVocabularyLevel.gentleCultivation => 'Current Realm',
      DaojiVocabularyLevel.daoStream => 'Current Realm',
      DaojiVocabularyLevel.immortalCultivation => 'Cultivation Realm',
    };
  }

  String _progressLabel(DaojiVocabularyLevel level) {
    return switch (level) {
      DaojiVocabularyLevel.practical => 'Keseimbangan',
      DaojiVocabularyLevel.gentleCultivation => 'Stream Balance',
      DaojiVocabularyLevel.daoStream => 'Stream Balance',
      DaojiVocabularyLevel.immortalCultivation => 'Meridian Resonance',
    };
  }
}

/// Small pill badge showing the current tree status.
class _StageBadge extends StatelessWidget {
  final bool isRecovery;
  final CultivationLanguageLevel languageLevel;
  const _StageBadge({required this.isRecovery, required this.languageLevel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isRecovery
        ? CalmTheme.secondaryBlue
        : theme.colorScheme.primary;
    final label = isRecovery
        ? CultivationStrings.seasonRecovery(languageLevel)
        : CultivationStrings.seasonGrowth(languageLevel);
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

/// Badge shown when balance index >= 0.8, indicating full canopy / optimal state.
class _FullCanopyBadge extends StatelessWidget {
  final CultivationLanguageLevel languageLevel;
  const _FullCanopyBadge({required this.languageLevel});

  @override
  Widget build(BuildContext context) {
    final color = Colors.amber;
    final label = switch (languageLevel) {
      CultivationLanguageLevel.plain => 'Kanopi Penuh',
      CultivationLanguageLevel.hybrid => 'Full Canopy',
      CultivationLanguageLevel.full => 'Full Canopy (满载)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ],
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

/// Stable night-sky overlay for Quiet Integration mode.
class QuietIntegrationOverlay extends StatelessWidget {
  const QuietIntegrationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned.fill(child: _QuietIntegrationGradient()),
        Positioned(left: 48, top: 56, child: _SoftStar(size: 3.5, alpha: 0.42)),
        Positioned(
          right: 72,
          top: 92,
          child: _SoftStar(size: 2.5, alpha: 0.36),
        ),
        Positioned(
          left: 96,
          bottom: 84,
          child: _SoftStar(size: 2.8, alpha: 0.32),
        ),
        Positioned(
          right: 44,
          bottom: 64,
          child: _SoftStar(size: 3.2, alpha: 0.38),
        ),
      ],
    );
  }
}

class _QuietIntegrationGradient extends StatelessWidget {
  const _QuietIntegrationGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CalmTheme.secondaryBlue.withValues(alpha: 0.12),
            CalmTheme.secondaryBlue.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _SoftStar extends StatelessWidget {
  final double size;
  final double alpha;

  const _SoftStar({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: alpha * 0.55),
            blurRadius: size * 2.8,
            spreadRadius: size * 0.8,
          ),
        ],
      ),
    );
  }
}

/// Stateful widget for subtle pulsing blue aura in Tribulation mode.
class TribulationAuraWidget extends StatefulWidget {
  const TribulationAuraWidget({super.key});

  @override
  State<TribulationAuraWidget> createState() => _TribulationAuraWidgetState();
}

class _TribulationAuraWidgetState extends State<TribulationAuraWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.08,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Colors.blue.shade700.withValues(alpha: _pulseAnimation.value),
                Colors.blue.shade300.withValues(
                  alpha: _pulseAnimation.value * 0.5,
                ),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
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
