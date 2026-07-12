import 'package:flutter/material.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/theme/theme.dart';
import '../../cultivation/cultivation_constants.dart';
import 'growth_map/growth_map_widget.dart';
import 'tree_season_overlays.dart';

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
    final theme = Theme.of(context);
    final isRecovery = season == Season.recovery;
    final isDormant = season == Season.dormant;
    final isTribulation = cultivationSeason == CultivationSeason.tribulation;
    final isQuietIntegration =
        cultivationSeason == CultivationSeason.quietIntegration;

    // â”€â”€ Wrap everything in a rounded clip â”€â”€
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            // â”€â”€ Neutral canvas for the conceptual tree view â”€â”€
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.18),
                ),
              ),
            ),

            // â”€â”€ Dynamic Domain Aura â”€â”€
            // Animated like a PowerPoint morph background wash when a stream is
            // focused/unfocused.
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: selectedDomain == null
                        ? Alignment.center
                        : const Alignment(0, 0.2),
                    radius: selectedDomain == null ? 0.42 : 0.72,
                    colors: [
                      (activeDomainColor ?? theme.colorScheme.primary)
                          .withValues(alpha: selectedDomain == null ? 0.00 : 0.32),
                      (activeDomainColor ?? theme.colorScheme.primary)
                          .withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // â”€â”€ Peta Pertumbuhan Konseptual â”€â”€
            // Keep the same GrowthMapWidget instance across focus/unfocus.
            // This lets AnimatedPositioned nodes morph between layouts instead
            // of replacing the whole map, creating a PPT "Morph"-like motion.
            Positioned.fill(
              child: GrowthMapWidget(
                width: width,
                height: height,
                activeDomainColor: activeDomainColor,
                selectedDomain: selectedDomain,
                onDomainTap: onDomainNavigate,
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              child: IgnorePointer(
                ignoring: selectedDomain == null || onDomainReset == null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  opacity: selectedDomain != null && onDomainReset != null
                      ? 1.0
                      : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutBack,
                    scale: selectedDomain != null && onDomainReset != null
                        ? 1.0
                        : 0.72,
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
                ),
              ),
            ),

            // â”€â”€ Quiet Integration state: night sky with stars, stable soft glow â”€â”€
            if (isQuietIntegration)
              const Positioned.fill(
                child: IgnorePointer(child: QuietIntegrationOverlay()),
              ),

            // â”€â”€ Tribulation state: blue aura with subtle pulse, not harsh/violent â”€â”€
            if (isTribulation)
              const Positioned.fill(
                child: IgnorePointer(child: TribulationAuraWidget()),
              ),

            // â”€â”€ Dormant state: dim/restful, never death/decay language â”€â”€
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

            // â”€â”€ Soft recovery veil: gentle rest visual, never death/decay language â”€â”€
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

            // â”€â”€ Snow overlay (Recovery mode) â”€â”€
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
