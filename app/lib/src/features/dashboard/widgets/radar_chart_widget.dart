import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> scores;
  final Set<String> activeDomains;
  final String? selectedDomain;
  final ValueChanged<String>? onDomainSelected;
  final DaojiVocabularyLevel vocabularyLevel;

  const RadarChartWidget({
    super.key,
    required this.scores,
    required this.activeDomains,
    this.selectedDomain,
    this.onDomainSelected,
    this.vocabularyLevel = DaojiVocabularyLevel.earth,
  });

  static const List<String> _domains = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];

  /// Pembulatan skor untuk tampilan ringkas (0-10).
  int _scoreOf(String domain) =>
      (scores[domain] ?? 0.0).clamp(0.0, 10.0).round();

  String _titleForLevel() {
    return switch (vocabularyLevel) {
      DaojiVocabularyLevel.mortal => 'Keseimbangan Hidup',
      DaojiVocabularyLevel.human => 'Stream Resonance',
      DaojiVocabularyLevel.earth => 'Stream Resonance',
      DaojiVocabularyLevel.heaven => 'Meridian Resonance',
    };
  }

  String _infoTitleForLevel() {
    return switch (vocabularyLevel) {
      DaojiVocabularyLevel.mortal => 'Interaksi domain',
      DaojiVocabularyLevel.human => 'Interaksi stream',
      DaojiVocabularyLevel.earth => 'Stream Resonance',
      DaojiVocabularyLevel.heaven => 'Meridian Resonance',
    };
  }

  /// Membangun label pembaca layar yang menyebutkan tiap domain dan skornya
  /// dalam urutan kanonik.
  String _buildSemanticsLabel() {
    final parts = _domains
        .map(
          (d) =>
              '${DaojiText.domainLabel(d, vocabularyLevel)} ${_scoreOf(d)} dari 10',
        )
        .join(', ');
    return 'Radar keseimbangan: $parts.';
  }

  Widget _buildClickableLabel(
    BuildContext context,
    ThemeData theme,
    String domain,
    bool isActive,
    bool isSelected,
    Color domainColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = TextStyle(
      fontSize: 11,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
      color: isSelected
          ? Colors.white
          : (isActive
                ? domainColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.35)),
    );

    return Material(
      color: isSelected
          ? domainColor
          : (isActive
                ? domainColor.withValues(alpha: isDark ? 0.12 : 0.06)
                : theme.colorScheme.onSurface.withValues(alpha: 0.03)),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: (isActive && onDomainSelected != null)
            ? () => onDomainSelected!(domain)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? domainColor
                  : (isActive
                        ? domainColor.withValues(alpha: 0.35)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: domainColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            isActive
                ? DaojiText.domainLabel(domain, vocabularyLevel, short: true)
                : '${DaojiText.domainLabel(domain, vocabularyLevel, short: true)} — Soon',
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(_infoTitleForLevel()),
          content: const Text(
            'Ketuk kartu nama untuk melihat kutipan, tips wawasan, atau menyaring dasbor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _titleForLevel(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: _infoTitleForLevel(),
                  onPressed: () => _showHelpDialog(context, theme),
                  icon: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: _buildSemanticsLabel(),
              image: true,
              child: SizedBox(
                height: 330,
                width: 330,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Center the custom paint radar chart
                    Positioned(
                      left: 45,
                      top: 45,
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: CustomPaint(
                          painter: _RadarChartPainter(
                            scores: scores,
                            primaryColor: theme.colorScheme.primary,
                            onBackgroundColor: theme.colorScheme.onSurface,
                            cardColor:
                                theme.cardTheme.color ??
                                theme.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    // Draw interactive labels at the corners
                    ...List.generate(6, (i) {
                      final domain = _domains[i];
                      final angle = (i * 60) * math.pi / 180 - math.pi / 2;
                      const centerCoord = 165.0;
                      const labelRadius = 126.0;
                      final x = centerCoord + labelRadius * math.cos(angle);
                      final y = centerCoord + labelRadius * math.sin(angle);

                      final isActive = activeDomains.contains(domain);
                      final isSelected = domain == selectedDomain;
                      final color = DomainColors.forDomain(domain);

                      return Positioned(
                        left: x - 55,
                        top: y - 22,
                        child: SizedBox(
                          width: 110,
                          height: 44,
                          child: _buildClickableLabel(
                            context,
                            theme,
                            domain,
                            isActive,
                            isSelected,
                            color,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDataTable(context, theme),
          ],
        ),
      ),
    );
  }

  /// Tabel data ringkas (Domain | Skor) sebagai fallback yang dapat dibaca
  /// pengguna dengan teknologi bantu maupun pengguna awas.
  Widget _buildDataTable(BuildContext context, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;
    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: onSurface.withValues(alpha: 0.7),
    );
    final cellStyle = TextStyle(
      fontSize: 11,
      color: onSurface.withValues(alpha: 0.6),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DaojiText.resolve(DaojiTextKey.mapDomainLabel, vocabularyLevel),
                  style: headerStyle,
                ),
              ),
              Text(
                DaojiText.resolve(DaojiTextKey.mapScoreLabel, vocabularyLevel),
                style: headerStyle,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: onSurface.withValues(alpha: 0.12)),
        ..._domains.map((domain) {
          final isActive = activeDomains.contains(domain);
          final isTappable = onDomainSelected != null;
          final row = Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isActive
                        ? DaojiText.domainLabel(domain, vocabularyLevel)
                        : '${DaojiText.domainLabel(domain, vocabularyLevel)} — Soon',
                    style: cellStyle.copyWith(
                      fontWeight: domain == selectedDomain
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text('${_scoreOf(domain)}/10', style: cellStyle),
              ],
            ),
          );

          if (!isActive || !isTappable) return row;

          // Area ketuk >= 44px tinggi dengan label tombol untuk pembaca layar.
          return Semantics(
            button: true,
            label: 'Fokus ${DaojiText.domainLabel(domain, vocabularyLevel)}',
            child: InkWell(
              onTap: () => onDomainSelected!(domain),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Align(alignment: Alignment.centerLeft, child: row),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color primaryColor;
  final Color onBackgroundColor;
  final Color cardColor;

  static const List<String> _domains = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];

  _RadarChartPainter({
    required this.scores,
    required this.primaryColor,
    required this.onBackgroundColor,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width / 2, size.height / 2) - 20;

    // Paints
    final gridPaint = Paint()
      ..color = onBackgroundColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = onBackgroundColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dataPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw concentric hexagons
    const int levels = 3;
    for (int i = 1; i <= levels; i++) {
      final radius = maxRadius * (i / levels);
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60) * math.pi / 180 - math.pi / 2;
        final point = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180 - math.pi / 2;
      final outerPoint = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, outerPoint, axisPaint);
    }

    // Draw filled scores polygon
    final dataPath = Path();
    for (int i = 0; i < 6; i++) {
      final domain = _domains[i];
      final rawScore = scores[domain] ?? 0.0;
      final normalizedScore = rawScore.clamp(0.0, 10.0) / 10.0;
      final radius = maxRadius * normalizedScore;
      final angle = (i * 60) * math.pi / 180 - math.pi / 2;

      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}
