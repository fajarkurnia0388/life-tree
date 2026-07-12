import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/services/error_logger_provider.dart';
import '../../../core/theme/theme.dart';
import '../../cultivation/cultivation_constants.dart';
import '../../cultivation/cultivation_provider.dart';
import '../../cultivation/cultivation_strings.dart';
import 'tree_capture_dialog.dart';
import 'tree_display_widget.dart';

/// Tree vitality card with capture and share functionality.
/// Wraps TreeDisplayWidget and adds cultivation info display.
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
  bool _showCultivationDetails = false;

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

      // Convert to image with high 3.0x resolution for crisp detail
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to obtain PNG byte data');
      }
      final pngBytes = byteData.buffer.asUint8List();

      final fileName =
          'daoji_${widget.cumulativeDays}d_${DateTime.now().millisecondsSinceEpoch}.png';

      // 1. Always save to temp directory for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pngBytes);

      // 2. On desktop, also save to Downloads
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
          ref.read(errorLoggerProvider).logError(
                e,
                stackTrace,
                context: 'TreeVitalityCard.saveToDownloads',
              );
        }
      }

      if (mounted) {
        showTreeCaptureSuccessDialog(
          context: context,
          pngBytes: pngBytes,
          tempFile: tempFile,
          fileName: fileName,
          downloadsDir: downloadsDir,
          downloadsFile: downloadsFile,
          cumulativeDays: widget.cumulativeDays,
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
      currentRealm.name,
      widget.cumulativeDays,
    );

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        journeyLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Toggle cultivation details
                    IconButton(
                      icon: Icon(
                        _showCultivationDetails
                            ? Icons.info
                            : Icons.info_outline,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCultivationDetails = !_showCultivationDetails;
                        });
                      },
                      tooltip: 'Detail Kultivasi',
                    ),
                    // Capture button
                    IconButton(
                      icon: _isCapturing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded, size: 20),
                      onPressed: _isCapturing ? null : _captureAndShareTree,
                      tooltip: 'Ambil Foto Pohon',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cultivation details (collapsible)
            if (_showCultivationDetails) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentRealm.name} (${currentRealm.chineseName})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentRealm.focus,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tree display with RepaintBoundary for capture
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: TreeDisplayWidget(
                cumulativeDays: widget.cumulativeDays,
                season: widget.season,
                activeDomainColor: widget.activeDomainColor,
                selectedDomain: widget.selectedDomain,
                onDomainNavigate: widget.onDomainNavigate,
                onDomainReset: widget.onDomainReset,
              ),
            ),
            const SizedBox(height: 12),

            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hari ke-${widget.cumulativeDays}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
